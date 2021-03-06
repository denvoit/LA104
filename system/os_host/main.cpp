#include "STM32F10x.h"
#include "source/bios/Bios.h"
#include "source/Execute.h"

/*
  shell.elf
  apps/generator/midi.elf
  fileman.elf apps/generator/midi -e apps/generator/midi.elf
  apps/generator.midi data/holiday.mid
*/

extern "C" uint32_t /*__attribute__((naked))*/ GetStackPointer();

class CTokenizer
{
  char* mString;

public:
  CTokenizer(char* str)
  {
    mString = str;
  }

  void GetToken(char* out, int maxLength)
  {
    for (int i=0; i<maxLength; i++)
    {
      out[i] = mString[i];
      if (mString[i] == 0)
      {
        mString += i;
        return;
      }
      if (mString[i] == ' ')
      {
        out[i] = 0;
        mString += i;
        mString++;
        return;
      }
    }
    mString += maxLength;
    out[maxLength] = 0;
  }
};

int main()
{
  BIOS::SYS::Init();
  BIOS::FAT::Init();
  BIOS::USB::Enable();
//  BIOS::USB::InitializeSerial();
  BIOS::USB::InitializeMass();
  BIOS::OS::SetArgument((char*)"");

  char shell[64] = "shell.elf";

  while (BIOS::KEY::GetKey() == BIOS::KEY::F3)
  {
      BIOS::DBG::Print("Safe mode, press F1 to continue.\n");
      while (BIOS::KEY::GetKey() != BIOS::KEY::F1);
  }

  while (1)
  {
    if (strlen(BIOS::OS::GetArgument()) == 0)
      BIOS::OS::SetArgument(shell);

    uint32_t address = 0;
    char filename[64];
    {
      CTokenizer tok(BIOS::OS::GetArgument());
      tok.GetToken(filename, 63);
      address = ElfExecute(filename);
    }

    if (!address)
    {
      BIOS::DBG::Print("Press F1 to retry.\n");
      while (BIOS::KEY::GetKey() != BIOS::KEY::F1);
      continue;
    }

    // keep argument - for file viewer
    //BIOS::OS::SetArgument((char*)""); 
    BIOS::OS::HasArgument();
    BIOS::SYS::Execute(address);

//    if (strlen(BIOS::OS::GetArgument()) > 0)
    if (BIOS::OS::HasArgument())
      strcpy(shell, filename);
    else
      BIOS::OS::SetArgument((char*)"");
  }
  return 0;
}

extern "C" 
{

void Halt()
{
  BIOS::DBG::Print("Application halted");
  while(1);
}

void _HandleAssertion(const char* file, int line, const char* cond)
{
  // prevent sprintf buffer overflow
  BIOS::DBG::Print("\n\nAssertion failed in ");
  BIOS::DBG::Print(file);
  BIOS::DBG::Print(" [%d]: ", line);
  BIOS::DBG::Print(cond);
  BIOS::DBG::Print("\n");
  Halt();
}

void NMIException(void)
{
  BIOS::DBG::Print("NMIException");    
  Halt();
}
/*
void HardFaultException(void)
{
   BIOS::DBG::Print("HardFaultException");    
   while(1);
}
*/
void MemManageException(void)
{
  BIOS::DBG::Print("MemManageException\n");    
  Halt();
}
void BusFaultException(void)
{
  BIOS::DBG::Print("BusFaultException\n");    
  Halt();
}

void UsageFaultException(void)
{
  BIOS::DBG::Print("UsageFaultException\n");    
  Halt();
}

#include "crash.h"

}