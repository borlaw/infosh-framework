function [Maware] = calcAwareness2(node1,node2,st2,Vattack,Mimmun,Maware)
  %Calculating node1 awareness got by node2.
  STRATEGY_DEFECT = 0;
  STRATEGY_COOPERATE = 1;    
  
  awareness = 0;
  if (st2==STRATEGY_COOPERATE)
    if (Vattack(node2)>0)
      %Node2 has been attacked, So it could have util information
      if (Mimmun(Vattack(node2),node1)==0)
        %Node1 has not yet inmmunization for attacked of Node2
        awareness = 1;
        %awareness = rand();
      end
    end
  end  
  
  Maware(node1,node2) = awareness;
  
end