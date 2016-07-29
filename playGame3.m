function [Mutility, Maware, Mimmun] = playGame3(Vattack,numNodes,Msharing,Mdep,Mtrust,Mrep,Vcost,Vstrategies,Mimmun)

%STRATEGIES
STRATEGY_DEFECT = 0;
STRATEGY_COOPERATE = 1;

Maware = zeros(numNodes,numNodes);
Mutility = zeros(numNodes,numNodes);

%Vaware = zeros(1,numNodes);
%VawareNatt = zeros(1,numNodes);
%Vutility = zeros(1,numNodes);
%VutilityNatt = zeros(1,numNodes);

Mserv = Mdep';

for node=1:numNodes
    for j=node+1:numNodes      
      %Initializae uShot to 0
      Ushot = [0 0];
      
      %Awareness for node n by j info
      [Maware] = calcAwareness2(node,j,Msharing(j,node),Vattack,Mimmun,Maware);
      %Awareness for j by node
      [Maware] = calcAwareness2(j,node,Msharing(node,j),Vattack,Mimmun,Maware);         
      
      %Function header: payoff(node1, node2, st1, st2, Vcia, Vcost, Mdep, Mtrust, Mrep, Vaware)
      [Ushot] = payoff2(node,j,Msharing(node,j),Msharing(j,node),Vcost,Mdep,Mtrust,Mrep,Maware,Vattack,Mimmun);        
      
      Mutility(node,j) = Ushot(1);
      Mutility(j,node) = Ushot(2);                    
    
      %UPDATE IMMUNIZATION MATRIX ACCORDING TO NODES INDEX AND THEIR STRATEGIES
      if ((Msharing(node,j)==STRATEGY_COOPERATE) && (Vattack(node)>0))
        Mimmun(Vattack(node),j)=1;
      end    

     
    end %for-j
  
end %for-node
  

end %function