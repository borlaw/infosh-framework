function [Vattack] = setNodeUnderAttack2(t,AdjM, attackBh, numAttacks, fixedVattack, defaultAttack)

node = 1;
numAttacksEpoch = 3;

Vattack = zeros(1,columns(AdjM));

if (attackBh == 0)%FIXED: select node under attack according to attack matrix defined in param file
  if (t > rows(fixedVattack))
    if (mod(t,rows(fixedVattack))==0)
      fvattack = fixedVattack(rows(fixedVattack));
    else  
      fvattack = fixedVattack(mod(t,rows(fixedVattack)));
    end        
  else
    fvattack = fixedVattack(t,:);
  end
  Vattack = fvattack;
%  for i=1:columns(fixedVattack)
%    if (fixedVattack(i)>0)
%      Vattack(i)=ceil(numAttacks*rand());
%    end
%  end

elseif (attackBh == 1)%RANDOM. Uniform distribution
  %SELECT ATTACKS
  VattackEpoch = zeros(1,numAttacksEpoch);
  for a=1:numAttacksEpoch
    VattackEpoch(a) = ceil(numAttacks*rand());      
  end  

  %Number of nodes under attack is represented by 'p' percentage
  p = 0.05;
  numNodesAttacked = ceil(p*columns(AdjM)); 
  
  for i=1:numNodesAttacked
      randomAttack = ceil(columns(VattackEpoch)*rand());   
      nodeUnderAttack = ceil(columns(AdjM)*rand());      
      Vattack(nodeUnderAttack) = VattackEpoch(randomAttack);      
  end
  
%  randU = rand(1,columns(AdjM)) ; 
%  VattackBool = (randU(1,:)<=p);
%  for i=1:columns(VattackBool)
%    if (VattackBool(i)==1)
%      randomAttack = ceil(numAttacks*rand());
%      Vattack(i) = randomAttack;
%    end
%  end

  
  %allDegrees = all connections in one node
  %inDegrees = Dependencies
  %outDegrees = Services
elseif (attackBh == 2)%Nodes with highest number of dependencies
  [allDegrees inDegrees outDegrees] = degrees(AdjM);    
  %To get highest amount of dependencies, sort inDegrees in descendent order  
  [deg idx] = sort(inDegrees,"descend");
  i = mod(t,columns(AdjM));
  if (i==0)
    i = columns(AdjM);
  end
  Vattack(idx(i)) = defaultAttack;
  
  
elseif (attackBh == 3)%Same as attachBh==2 but random attack and random node with probability.
  %The higher the number the dependencies, the more likely your are to receive an attack.
  [allDegrees inDegrees outDegrees] = degrees(AdjM);
  %To get highest amount of dependencies, sort inDegrees in ascendent order
  [deg idx] = sort(inDegrees,"descend");  
  
  distNode = (deg./columns(deg));
  %distNode = (deg./columns(deg));
  
  %pNode = rand(1,columns(deg))+0.1
  %p = rand();
  
  %Vrandom = zeros(1,columns(deg));
  for i=1:columns(distNode)
    %If one node has no dependencies, default probability is 2%
    if (distNode(i)==0)
      distNode(i)=0.02;
    end    
    p = rand();    
    if (p<=distNode(i))
      %NODE UNDER ATTACK. WITH RANDOM ATTACK
      %printf("p<distNode(%i)\n",i);
      %distNode(i)            
      randomAttack = ceil(numAttacks*rand());     
      Vattack(i)=randomAttack;
    end
  end    
  
elseif (attackBh == 4)%Nodes offering highest number of services
  [allDegrees inDegrees outDegrees] = degrees(AdjM);
  %To get highest amount of dependencies, sort outDegrees in descendent order
  [deg idx] = sort(outDegrees,"descend");
  i = mod(t,columns(AdjM));
  if (i==0)
    i = columns(AdjM);
  end
  Vattack(idx(i)) = defaultAttack;
  
  
elseif (attackBh == 5)%Nodes offering highest number of services. Random attack and random node with probability according to number of services
  [allDegrees inDegrees outDegrees] = degrees(AdjM);
  %To get highest amount of services offered, sort outDegrees in descent order
  [deg idx] = sort(outDegrees,"descend");
  
  distNode = (deg./columns(deg));
  %p = rand();
  
  for i=1:columns(distNode)
    %If one node does not offer any service, default probability is 2%
    if (distNode(i)==0)
      distNode(i)=0.02;
    end    
  
    p = rand();
    if (p<=distNode(i))
      %NODE UNDER ATTACK. WITH RANDOM ATTACK
      %printf("p<distNode(%i)\n",i);
      %distNode(i)            
      randomAttack = ceil(numAttacks*rand());     
      Vattack(i)=randomAttack;
    end
  end      

elseif (attackBh == 6)%Selecting 3 random attacks from Vector of attacks and random selection of nodes attacked as in case 3
  %SELECT ATTACKS

  VattackEpoch = zeros(1,numAttacksEpoch);
  for a=1:numAttacksEpoch
    VattackEpoch(a) = ceil(numAttacks*rand());      
  end  
  
  [allDegrees inDegrees outDegrees] = degrees(AdjM);
  %To get highest amount of services offered, sort outDegrees in descent order
  [deg idx] = sort(inDegrees,"descend");
  
    %distNode = (deg./columns(deg))
  distNode = (deg./max(deg)-0.3);
  %p = rand();
  
  for i=1:columns(distNode)
    %If one node does not offer any service, default probability is 2%
    if (distNode(i)==0)
      distNode(i)=0.01;
    end    
  
    p = rand();
    if (p<=distNode(i))
      %NODE UNDER ATTACK. WITH RANDOM ATTACK
      %printf("p<distNode(%i)\n",i);
      %distNode(i)            
      randomAttack = ceil(columns(VattackEpoch)*rand());     
      %Vattack(i) = VattackEpoch(randomAttack);
      Vattack(idx(i)) = VattackEpoch(randomAttack);

    end
  end      

elseif (attackBh == 7)%Selecting 3 random attacks from Vector of attacks and random selection of nodes attacked as in case 3
  %SELECT ATTACKS

  VattackEpoch = zeros(1,numAttacksEpoch);
  for a=1:numAttacksEpoch
    VattackEpoch(a) = ceil(numAttacks*rand());      
  end  
  
  [allDegrees inDegrees outDegrees] = degrees(AdjM);
  %To get highest amount of services offered, sort outDegrees in descent order
  [deg idx] = sort(outDegrees,"descend");
  
   
  %distNode = (deg./columns(deg))
  distNode = (deg./max(deg)-0.3);
  %p = rand();
  
  for i=1:columns(distNode)
    %If one node does not offer any service, default probability is 2%
    if (distNode(i)==0)
      distNode(i)=0.01;
    end    
  
    p = rand();
    if (p<=distNode(i))
      %NODE UNDER ATTACK. WITH RANDOM ATTACK
      %printf("p<distNode(%i)\n",i);
      %distNode(i)            
      randomAttack = ceil(columns(VattackEpoch)*rand());           
      %Vattack(i) = VattackEpoch(randomAttack);
      Vattack(idx(i)) = VattackEpoch(randomAttack);      
    end
  end  
  
else
  %TO-DO: selecting node according to centrality measures
  node = 1;
  
end


end