#include "llvm/Pass.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/InstVisitor.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/ADT/SmallVector.h"
#include<iostream>
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/ConstantFolding.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/Cloning.h"

using namespace llvm;

namespace {

typedef enum {
    UNDEF,
    NAC,
    CONST
} ValueState;

class ValueContainer{
    public: 
    ValueState State;
    llvm::Constant *ConstantValue;
    Instruction *Inst;
    ValueContainer(Instruction *instr)
    {
        Inst = instr;
        if(!areAllOperandsConstants())
        {
            State = NAC;
        }

        ConstantValue = llvm::ConstantFoldInstruction(Inst, Inst->getModule()->getDataLayout());
        if(!ConstantValue)
        {
            State = NAC;
        }
        else
        {
            State = CONST;
        }
    }

    bool areAllOperandsConstants() {
        for (unsigned i = 0, e = Inst->getNumOperands(); i != e; ++i) { 
            llvm::Value *Op = Inst->getOperand(i);
            if (!llvm::isa<llvm::Constant>(Op)) {
                return false;
            }
        }
        return true;
    }

    void ReplaceUse(llvm::Instruction *userInst)
    {
        for (unsigned j = 0; j < userInst->getNumOperands(); j++) {
            if (userInst->getOperand(j) == Inst) {
                userInst->setOperand(j, ConstantValue);
            }
        }
    }
};

bool isInlineable(CallInst *call) {
    Function *calledFunction = call->getCalledFunction();
    if (!calledFunction || calledFunction->isDeclaration()) {
        return false; 
    }

    // Check if all arguments are constants
    bool allArgsConstants = true;
    for (unsigned i = 0, e = call->getNumOperands(); i != e; ++i) {
        if (!isa<Constant>(call->getOperand(i))) {
            allArgsConstants = false;
            return false;
        }
    }
    return true;
}


struct ConstantPropogation : public FunctionPass {
  static char ID;
  ConstantPropogation() : FunctionPass(ID) {}

  bool runOnFunction(Function &F) override {
    llvm::SmallVector<ValueContainer, 16> WorkList;
    llvm::SmallVector<llvm::CallInst*, 16> InlineableCalls;

    /*Begin by inlining functions to provide maximum oppurtunity to 
    "catch" constants in the worklist further down*/
    for(BasicBlock &BB : F)  
    {
      for(Instruction &inst : BB)
      {
        if (llvm::isa<llvm::CallInst>(inst)) { //We try to find function calls with all values predefined -- INLINE them!!
            llvm::CallInst *Callinst = dyn_cast<llvm::CallInst>(&inst);
            if(isInlineable(Callinst))
            {
                InlineableCalls.push_back(Callinst);
            }
        }
      }
    }

    bool allInlineSuccess = true;

    while(!InlineableCalls.empty()){
        llvm::CallInst *inst = InlineableCalls.pop_back_val();
        Function *calledFn = inst->getCalledFunction();

        ValueToValueMapTy VMap;
        auto argIter = calledFn->arg_begin();
        for (unsigned i = 0; i < inst->getNumOperands() - 1; ++i, ++argIter) {
            VMap[&*argIter] = inst->getOperand(i);
        }

        InlineFunctionInfo IFI;
        if(!InlineFunction(*inst,IFI).isSuccess()){
            allInlineSuccess = false;
        }
    }

    for(BasicBlock &BB : F)  //Iterate over the basic blocks
    {
      for(Instruction &inst : BB) //Iterate over the instructions
      {
        ValueContainer newVc(&inst);
        if(newVc.ConstantValue)
        {
            WorkList.insert(WorkList.begin(),newVc);
        }
      }
    }

    //Worklist for reaching defs of constants
    while (!WorkList.empty()) {
        ValueContainer WorklistItem = WorkList.pop_back_val();
        llvm::errs() << *WorklistItem.Inst << "\n";
        llvm::Instruction *instr = WorklistItem.Inst;
        llvm::Constant *constant = WorklistItem.ConstantValue;

        llvm::SmallVector<llvm::Instruction*, 8> ValidUseList;

        for (auto &Use : instr->uses()) {
            llvm::User *user = Use.getUser();  // User is anything that uses the instr
            if (llvm::Instruction *userInst = llvm::dyn_cast<llvm::Instruction>(user)) {
                ValidUseList.push_back(userInst);
            }
        }


        while(!ValidUseList.empty())
        {
            llvm::Instruction *userInstr = ValidUseList.pop_back_val();
            errs()<<*userInstr<<"\n";
            WorklistItem.ReplaceUse(userInstr);
            ValueContainer newVc(userInstr);
            if(newVc.State == CONST)
                WorkList.insert(WorkList.begin(),newVc);
            // errs()<<*userInstr<<"\n";
        }

        if (!instr->mayHaveSideEffects() && instr->use_empty()) {
            instr->eraseFromParent();
        }
        errs()<<" \n\n";
    }

    return false;
  }

}; // end of struct Hello
}  // end of anonymous namespace

char ConstantPropogation::ID = 0;
static RegisterPass<ConstantPropogation> X("function-info", "Constant Folding Pass",
                             false /* Only looks at CFG */,
                             false /* Analysis Pass */);