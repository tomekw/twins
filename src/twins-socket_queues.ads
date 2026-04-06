with Ada.Containers.Synchronized_Queue_Interfaces;
with Ada.Containers.Bounded_Synchronized_Queues;
with GNAT.Sockets;

package Twins.Socket_Queues is
   package Socket_Queue_Interfaces is new Containers.Synchronized_Queue_Interfaces
      (Element_Type => Sockets.Socket_Type);

   package Bounded_Socket_Queues is new Containers.Bounded_Synchronized_Queues
      (Queue_Interfaces => Socket_Queue_Interfaces,
       Default_Capacity => 64);

   Socket_Queue : Bounded_Socket_Queues.Queue;
end Twins.Socket_Queues;
