!--------------------------------------------------------------------------------------------------
! 
! Callback to Clarion class methods
!
! 2015.10.26 by Viggo Kleven
!
!--------------------------------------------------------------------------------------------------      
! Setting up callbacks to class methods using a fixed set of callback functions so that each class
! instance calls individual callback function controlled by an instance counter. 
! Each callback function will assign correct class instance for the actual callback.
! The callback functions are fixed, but as the Class references are threaded the actual callbacks
! into the classes are isolated between threads.  This way each thread can have up to 3 instances
! of the class with callback registered.  
! 
! The callbacks can come from any external library with a given parameter set.
!
! Challenge: What are the options to make this dynamic to avoid a fixed set of callback funtions?
!--------------------------------------------------------------------------------------------------

  PROGRAM

  INCLUDE('AppLog.inc'), ONCE

  MAP
CB1 PROCEDURE() !, PASCAL    ! Instance 1 callback
CB2 PROCEDURE() !, PASCAL    ! Instance 2 callback
CB3 PROCEDURE() !, PASCAL    ! Instance 3 callback
Thread1 PROCEDURE()  ! testing sep thread
  END

CBclassType CLASS, TYPE
Ident         LONG
Init          PROCEDURE()
CallBack      PROCEDURE( BYTE pInstance )
            END

CBClass1  CBClassType
CBClass2  CBClassType
CBClass3  CBClassType
CBClass4  CBClassType

CBCref1   &CBClassType, THREAD ! Instance ref #1  (thread har no purpose as the callbacks are shared across all threads using the class!
CBCref2   &CBClassType, THREAD ! Instance ref #2
CBCref3   &CBClassType, THREAD ! Instance ref #3
InstCount BYTE(0),      THREAD ! Instance Count

!--------------------------------------------------------------------------------------------------

  CODE

  CBClass1.Ident = 111
  CBClass1.Init()

  CBClass2.Ident = 222
  CBClass2.Init()

  CBClass3.Ident = 333
  CBClass3.Init()

  CBClass4.Ident = 444
  CBClass4.Init()

  START(Thread1)
  
  CB1()
  
!--------------------------------------------------------------------------------------------------
! A separate thread to confirm that even the callback function itself is fixed, the class it points
! to is threaded. This means that each thread can have a full set of callback functions.
!--------------------------------------------------------------------------------------------------
Thread1 PROCEDURE()
CBClass888  CBClassType

  CODE

   CBClass888.Ident = 888
   CBClass888.Init()
   CB1()
   
!--------------------------------------------------------------------------------------------------
! The callback functions per class instance
!--------------------------------------------------------------------------------------------------
CB1 PROCEDURE() !, PASCAL !, NAME('MyCB1')    ! Instance 1 callback
  CODE
  IF NOT CBCref1 &= NULL
    CBCref1.Callback(1)
  END
  
CB2 PROCEDURE() !, PASCAL !, NAME('MyCB1')    ! Instance 2 callback
  CODE
  
  IF NOT CBCref2 &= NULL
    CBCref2.Callback(2)
  END
  
CB3 PROCEDURE() !, PASCAL !, NAME('MyCB1')    ! Instance 3 callback
  CODE

  IF NOT CBCref3 &= NULL
    CBCref3.Callback(3)
  END
  
!--------------------------------------------------------------------------------------------------
! Class implementation
! 
! The Init method sets up the callback according to class instance, limitied to 3 instances
!--------------------------------------------------------------------------------------------------
CBClassType.Init PROCEDURE()

  CODE
   
   InstCount +=1
   CASE Instcount    
   OF 1
    CBCref1 &= SELF
    CB1() ! simulate callback to instance 1 (normally we'll register the callback here)
    
   OF 2
    CBCref2 &= SELF
    CB2() ! simulate callback to instance 2

   OF 3
    CBCref3 &= SELF
    CB3() ! simulate callback to instance 3

   ELSE
    LOG_Debug('No more instances available for callback')
    ! This can either be ok - using the class instance without callback, or set error to signal that no more instances is possible.
   END
   
!--------------------------------------------------------------------------------------------------
! This is the actual callback worker method
!--------------------------------------------------------------------------------------------------
CBClassType.CallBack PROCEDURE( BYTE pInstance)

  CODE        
    
  LOG_Debug('Inside MyClass.CallBack() for instance ' & pInstance & ' ident: ' & SELF.Ident & ' Thread: ' & THREAD() )
 
!--------------------------------------------------------------------------------------------------

