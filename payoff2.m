%-------------------------------------------------------------------------------
%PARAMS
%-------------------------------------------------------------------------------
%1- node1: node A in this shot
%2- node2: node B in this shot
%3- st1: selected strategy by node A: cooperate(=0) VS defect(=1)
%4- st2: selected strategy by node B: cooperate(=0) VS defect(=1)
%5- Vcia: CIA vector. CIA values for each node in the graph
%6- Vcost: Estimated initial cost for sharing vector. Costs for each node in the graph 
%7- Mdep: dependency matrix of the whole graph 
%8- Mtrust: trust matrix of the whole graph
%9- Vrep: reputation vector for each node
%10- Vware: wareness vector for each node
%11- Mweigth: weigth matrix for each parameter and node. Size of this matrix is: Nx4, 
%where N is number of nodes in the graph and 4 are the parameters in the game model: dependency, trust, reputation and awareness.
%IN THIS VERSION This last parameter is not implemented
function [utility] = payoff2(node1, node2, st1, st2, Vcost, Mdep, Mtrust, Mrep, Maware, Vattack, Mimmun)
STRATEGY_DEFECT = 0;
STRATEGY_COOPERATE = 1;

utility = [0 0];
gain1 = 0;
cost1 = 0;
gain2 = 0;
cost2 = 0;


%CONTROL DEPENDENCIES WITH 0 VALUES.
%If any node offer a service to another node, we assume a residual dependency (>0)
depByService = 0.02;

if (Mdep(node1,node2)==0)
  Mdep(node1,node2)=depByService;
end

if (Mdep(node2,node1)==0)
  Mdep(node2,node1)=depByService;
end

VawGame = [0 0];

if (st1==STRATEGY_COOPERATE) && (st2==STRATEGY_COOPERATE) 

  %Player A
  %gain1 = Mrep(node1,node2) * Maware(node1,node2);  
  gain1 = Mrep(node1,node2) + Maware(node1,node2);    
  cost1 = Vcost(node1)/Mtrust(node1,node2); 
  
  %Player B
  %gain2 = Mrep(node2,node1) * Maware(node2,node1);
  gain2 = Mrep(node2,node1) + Maware(node2,node1);
  cost2 = Vcost(node2)/Mtrust(node2,node1);


elseif (st1==STRATEGY_COOPERATE) && (st2==STRATEGY_DEFECT)
  %Player A
  gain1 = Mrep(node1,node2);
  cost1 = Vcost(node1)/Mtrust(node1,node2);

  %Player B
  %gain2 = Vcost(node2) * Maware(node2,node1);
  gain2 = Vcost(node2) + Maware(node2,node1);
  cost2 = Mrep(node2,node1);


elseif (st1==STRATEGY_DEFECT) && (st2==STRATEGY_COOPERATE)
  %Player A
  %gain1 = Vcost(node1) * Maware(node1,node2);
  gain1 = Vcost(node1) + Maware(node1,node2);
  cost1 = Mrep(node1,node2);
  
  %Player B
  gain2 = Mrep(node2,node1);
  cost2 = Vcost(node2)/Mtrust(node2,node1);

elseif (st1==STRATEGY_DEFECT) && (st2==STRATEGY_DEFECT)
  
  %Player A
  gain1 = Vcost(node1);
  %cost1 = Mrep(node1,node2) * Maware(node1,node2);
  cost1 = Mrep(node1,node2) + Maware(node1,node2);

  %Player 2
  gain2 = Vcost(node2);
  %cost2 = Mrep(node2,node1) * Maware(node2,node1);
  cost2 = Mrep(node2,node1) + Maware(node2,node1);
  
end %if-strategies

utility(1) = gain1 - cost1;
utility(2) = gain2 - cost2;


end %function