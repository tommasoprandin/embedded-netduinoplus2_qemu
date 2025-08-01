------------------------------------------------------------------------------
--                                                                          --
--                 GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                 --
--                                                                          --
--                     S Y S T E M . I N T E R R U P T S                    --
--                                                                          --
--                                  S p e c                                 --
--                                                                          --
--                     Copyright (C) 2001-2025, AdaCore                     --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNARL was developed by the GNARL team at Florida State University.       --
-- Extensive contributions were provided by Ada Core Technologies, Inc.     --
--                                                                          --
------------------------------------------------------------------------------

--  This is the Ravenscar version of this package

--  Note: the compiler generates direct calls to this interface, via Rtsfind.
--  Any changes to this interface may require corresponding compiler changes.

--  This package provides the required support for the implementation of
--  ``Ada.Interrupts``, using GNULL primitives. This package has been
--  specifically tailored to meet the Ravenscar Profile restrictions on all
--  bare board Ravenscar targets.
--
--  This package provides the interface to install a protected handler. Its
--  implementation is based on providing a table where the interrupt
--  handlers are registered, so that the appropriate interrupt handler is
--  invoked.
--
--  An interrupt wrapper is defined in the body of this package which is the
--  one that is actually registered as the handler in the underlying
--  executive layer.

with System.OS_Interface;

package System.Interrupts is
   pragma Elaborate_Body;

   -------------------------
   -- Constants and types --
   -------------------------

   Default_Interrupt_Priority : constant System.Interrupt_Priority :=
                                  System.Interrupt_Priority'Last;
   --  Default value used when a pragma Interrupt_Handler or Attach_Handler is
   --  specified without an Interrupt_Priority pragma, see D.3(10).

   type Ada_Interrupt_ID is new System.OS_Interface.Interrupt_Range;
   --  Avoid inheritance by Ada.Interrupts.Interrupt_ID of unwanted operations

   type Interrupt_ID is new System.OS_Interface.Interrupt_Range;

   --  The following renaming is introduced so that the type is accessible
   --  through rtsfind, otherwise the name clashes with its homonym in
   --  ada.interrupts.

   subtype System_Interrupt_Id is Interrupt_ID;

   type Parameterless_Handler is access protected procedure;

   type Handler_Index is range 0 .. Integer'Last;

   type Handler_Item is record
      Interrupt : Interrupt_ID;
      Handler   : Parameterless_Handler;
   end record;
   --  Contains all the information from an Attach_Handler pragma

   type Handler_Array is array (Handler_Index range <>) of Handler_Item;

   --------------------------------
   -- Interrupt entries services --
   --------------------------------

   -----------------------------
   -- Interrupt entry service --
   -----------------------------

   procedure Install_Restricted_Handlers
     (Prio     : Interrupt_Priority;
      Handlers : Handler_Array);
   --  Install the static Handlers for the given Interrupts. There is one call
   --  per protected object, and one element in Handlers for each handler of
   --  the protected object (typically only one). Prio is the priority of
   --  the protected object, so that interrupt controler can be set to that
   --  priority (if possible).

   procedure Install_Restricted_Handlers_Sequential;
   pragma Export (C, Install_Restricted_Handlers_Sequential,
                  "__gnat_attach_all_handlers");
   --  When the partition elaboration policy is sequential, attachment of
   --  interrupts handlers is deferred until the end of elaboration. The
   --  binder will call this procedure at the end of elaboration, just before
   --  activating the tasks (if any).
end System.Interrupts;
