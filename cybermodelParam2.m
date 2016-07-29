function [Ac_cia, Ac_rep, Ac_aw, Ac_u, Ac_stg, Ac_sh, Mattack, Mimmun, MAX_EPOCH] = cybermodelParam2(params)

addpath("./ga")
addpath("./net-tb");
%function [] = cybermodel()
%REQUIRED PACKAGES%
%octave-networks-toolbox: https://github.com/aeolianine/octave-networks-toolbox/wiki/List-of-functions
  
%------------------------------------------------------------------------------%  
%CONSTANTS
%------------------------------------------------------------------------------%
%STATES
STATE_OPERATIVE = 0;
STATE_ATTACKED  = 1;
STATE_IMPACTED  = 2;

NO_SPREAD = 0;
SPREAD = 1;

%STRATEGIES
STRATEGY_DEFECT = 0;
STRATEGY_COOPERATE = 1;

%NUM_ATTACKS = 9;


%------------------------------------------------------------------------------%
%PARAMS%
%------------------------------------------------------------------------------%
load(params)
propagationMode = 1;
%NUM_ATTACKS = 0.9 * numNodes;
NUM_ATTACKS = 10;
  
%------------------------------------------------------------------------------%
%NETWORK SETUP
%------------------------------------------------------------------------------%
%Network setup is based on Scale-Free Network, since it is demonstrated that best fit to Internet topology.
 
%Network seed based on critical infrastructure scenario described in not finished paper (16x16)
%networkSeed = [0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 1; 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0; 0 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0; 0 0 0 0 0 0 1 0 0 0 1 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1; 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0; 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
%net = SFNG(numNodes,1,networkSeed);
net = networkSeed;

%Plot graph associated with Adjacency matrix using Graphviz (through pmtk3 project (graphviz.m) that I have included in Octave install directory [./pmtk3-master])
%graphviz(networkSeed,'filename', 'scenario', 'labels', {'TIC-Cloud','TIC-Router','TIC-OSS','TIC-OLT','TRANS-FW1','TRANS-Web-Pub','TRANS-Web-Priv','TRANS-DB','TRANS-Hosts','TRANS-FW2','TRANS-Logistic-Mng','ENER-FW','ENER-Web-Pub','ENER-SCADA-DB','ENER-SCADA','ENER-Hosts'})
%graphviz(net,'filename', 'scenario');


%------------------------------------------------------------------------------%
%INITIALIZATION: t1
%------------------------------------------------------------------------------%
%Services: adjacency matrix that represents services offered from nodes to nodes
Mserv = net;

%Dependencies: 
%Old approach: inverse adjacency matrix of services matrix
Mdep = Mserv';

%New approach: calculate indirect services trough graph paths
printf("Calculating dependencies\n");
%MservInd = calculateDependencies(Mserv);

%Trusts: trust matrix among adjacent nodes
%MtrustIni = [1 0.5 0.5 0.5 0.5; 0.5 1 0.5 0.5 0.5; 0.5 0.5 1 0.5 0.5; 0.5 0.5 0.5 1 0.5; 0.5 0.5 0.5 0.5 1];
%Mtrust = MtrustIni;
printf("Generating Trust Matrix\n");
Mtrust = genMtrust(numNodes,trustBh,trustIni);

%Initial CIA Values: vector
%VciaIni = [0.8 0.8 0.8 0.8 0.8];
%Vcia = VciaIni;
printf("Generating CIA Vector\n");
Vcia = genVcia(numNodes,ciaBh,ciaIni);

%Initial Estimated Cost Values; VECTOR
VcostIni = k*Vcia;
Vcost = VcostIni;

%Initialize Immunization Vector. All nodes with immunization factor = 0
%Vimmun = zeros(1,numNodes); 
Mimmun = zeros(NUM_ATTACKS,numNodes);

%Initialize propagation vector. This vector is used for managing the propagation of cyberattacks
Vpropagation = zeros(1,numNodes);
Mpropagation = [];

%Initialize states vector. This vector is used for setting the nodes states
Vstates = zeros(1,numNodes);
%Vattack = zeros(1,MAX_EPOCH);%Vector for set node under attack for each epoch
Vattack = zeros(1,numNodes);
Mattack = [];
Veffect = zeros(1,numNodes);
vdefaultAttackEffect = [];

[VdefaultAttackEffect] = setDefaultAttackEffect(NUM_ATTACKS);

%Initialize Strategies for all nodes: initially every node STRATEGY_COOPERATE=0
%Vstrategies = zeros(numNodes);
%Initial Vstrategies only valid when strategy si locally stablished
Vstrategies = genVstrategies(numNodes,randomVstrategies,gameStgLocal,gameStg,defaultVstrategies);
Mstrategies = [];

Msharing= zeros(numNodes,numNodes);

%Initialize Awareness vector for all nodes
Vaw = zeros(1,numNodes);
VawSum = zeros(1,numNodes);%Sum of all awareness
VawHist = zeros(1,numNodes);%VawSum / Epoch

%Reputation vector
%Vrep = ones(1,numNodes);
Mrep = ones(numNodes,numNodes);

Ac_cia = [0 Vcia];
Ac_rep = [];
Ac_aw = [];
Ac_u = [];
Ac_stg = [];
Ac_sh = [];

save "ini-values.mat" Vcia Mtrust
 

%------------------------------------------------------------------------------
%ALGORITHM-MODEL
%------------------------------------------------------------------------------
%printf("INITIAL CIA Vector:\n")
%Vcia

%for t=1:MAX_EPOCH
t = 1;
endSimulation = 0;

while (endSimulation == 0)

  vt = ones(numNodes,1);
  vt = t * vt;
  printf("Epoch %d#\n",t);
  
  %****************************************************************************
  %****************************************************************************
  %CYBER ATTACK TREATMENT                                                      
  %****************************************************************************
  %****************************************************************************  
  VattackEffect = zeros(1,numNodes);
  MimmunPrev = Mimmun;
  
  %defaultAttack = 4;
  %printf("Selecting node under attack\n");
  [Vattack] = setNodeUnderAttack2(t,Mserv,attackBh,NUM_ATTACKS,NodesCyberAttack,defaultAttack);%params: Adjacency Matrix, Num Attacks, Option.  

  %Set attack effect
  %printf("Calculating attack effect\n");
  [Veffect] = setAttackEffect2(Vattack,VdefaultAttackEffect);%params: Node under Attack, Type of Attack.
      
  %Trace, check if CIA gets higher
  %VciaPrev = Vcia;   
  %VstatesPrev = Vstates;
  %VpropagationPrev = Vpropagation;
  %MimmunPrev = Mimmun;
      
  %Cyberattacks effects in nodes under attack
  for i=1:columns(Vattack)
    if (Vattack(i)>0) 
      VattackEffect(i) = Veffect(i) * (1 - Mimmun(Vattack(i),i));
      Vcia(i) = Vcia(i) - abs((Vcia(i) * VattackEffect(i)));                  
      Vstates(i) = STATE_ATTACKED;      
      %Update propagation vector. The node under attack has attack propagated
      %Only propagate effects if attack has an impact in node
      if (VattackEffect(i) > 0)
          Vpropagation(i) = SPREAD;
      end      
      
      Mimmun(Vattack(i),i) = 1;      
    end
  end
  
  Mattack = vertcat(Mattack,Vattack);
  Mpropagation = vertcat(Mpropagation,Vpropagation);  
  
  %****************************************************************************
  %****************************************************************************
  %PROPAGATION                                                                 
  %****************************************************************************
  %****************************************************************************
  
  %printf("Propagating attack effect\n");
  [VciaNew, VstatesNew, VpropagationNew] = propagateAttack2(Mserv, MservInd,Vstates,Vpropagation,VattackEffect,Vcia, propagationMode);  
  %printf("NEW CIA Vector:\n");
  %VciaNew
    
  %Re-set vectors
  Vcia = VciaNew;
  Vstates = VstatesNew;
  Vpropagation = VpropagationNew;  
  
  %****************************************************************************
  %****************************************************************************
  %INFORMATION SHARING DECISION
  %****************************************************************************
  %****************************************************************************

  %----------------------------------------------------------------------------
  %SELECT STRATEGY FOR EACH NODE
  %----------------------------------------------------------------------------        
  %printf("Setting Vstrategies and selecting sharing decision\n");
  [Vstrategies] = setVstrategies(numNodes,gameStgLocal,stgEpoch,gameStg,Vstrategies);
  Mstrategies = vertcat(Mstrategies,Vstrategies);
  
  %Vstrategies = selectStrategy2(Vattack,VstrategiesOld,gameStg);  
  MsharingOld = Msharing;
  [Msharing] = selectStrategy3(Vattack,Vstrategies,MsharingOld,Mserv)  ;
  %printf("ESTRATEGIAS DE JUEGO\n");
  %Vstrategies
  
  %Ac_stg = vertcat(Ac_stg,[t Vstrategies]);  
  Ac_stg = Mstrategies;
  Ac_sh = vertcat(Ac_sh,Msharing);
  
  %----------------------------------------------------------------------------
  %PLAY GAME
  %----------------------------------------------------------------------------      
  %printf("Playing game\n");
  Mutility = [];
  Maware = [];
  %Function to decide share or not to share among nodes: PLAY A GAME 
  %[Mutility, Maware, Mimmun, Mplay] = playGame2(Vattack,numNodes,Mdep,Mtrust,Mrep,Vcost,Vstrategies,Mimmun,pairsOpt);  
  [Mutility, Maware, Mimmun] = playGame3(Vattack,numNodes,Msharing,Mdep,Mtrust,Mrep,Vcost,Vstrategies,Mimmun);  
    
  %printf("Utilities for node %d in epoch %d:\n",n,t);
  %Vutility
  
  %Update Immunization Matrix
  %*******************************TO-DO************************************  

  %----------------------------------------------------------------------------
  %UPDATE VALUES FOR NEXT EPOCH
  %----------------------------------------------------------------------------    
  
  %**********************************
  %***UPDATE CIA BECAUSE OF SHARING**
  %**********************************
  %ONLY IF THE NODE HAS BEEN ATTACKED BY AN ATTACK THAT IT IS NOT IMMUNIZED AND APPLY A 
  
  %printf("Updating CIA\n");  
  [MutilityClean] = avgMatrix(Mutility);
  for i=1:numNodes
    if ((Vattack(i)>0) && (MimmunPrev(Vattack(i),i)==0) && (max(Msharing(i,:))==1) && (mean(MutilityClean(i))<0))          
      Vcia(i) = Vcia(i) - Vcost(i);
    end
    
%    %Node under attack       
%    if (mean(MutilityClean(i)) < 0)
%      Vcia(i) = Vcia(i) - (2 * Vcost(i));
%    else
%      Vcia(i) = Vcia(i) - Vcost(i);
%    end
%    else
%      if (Vstrategies(i) == STRATEGY_COOPERATE)
%      %El resto de nodos ven afectado su CIA cuando también intercambian info (coste de compartir)
%      %Si no comparte, el CIA que pierden sólo es por efectos en la propagación de ciberataques  
%      Vcia(i) = Vcia(i) - Vcost(i);      
%      end        
%    end    
  end
  %Vcia(n) = Vcia(n)*mean(Vutility);  
  
  for i=1:columns(Vcia)
    if (Vcia(i)<0)
      Vcia(i)=0;
    end
  end
  Ac_cia = vertcat(Ac_cia,[t Vcia]);
  
  %***************  
  %UPDATE AWARENESS
  %***************
  %El awareness lo estoy actualizando dependiendo de las estrategias seguidas por cada uno. 
  %Si hay info-sharing, considero un Awareness de 1, que podría representar un factor de inmunización de 1.  
  %VawSum = VawSum + Vaware;
  %VawHist = VawSum / t; 
    
  Ac_aw = vertcat(Ac_aw, [vt Maware]);
  Ac_u = vertcat(Ac_u, [vt MutilityClean]);
  
  %***************
  %UPDATE REPUTATION
  %***************
  %OPCIÓN DE IMPL A: considerar juego de información perfecta (los nodos conocen las etrategias del resto
  %la reputación depende directamente de la estrategia seguida en la ronda y del número total de rondas
  %Num_iteraciones_comparte_info / Num_Total_iteraciones


  %OPCIÓN DE IMPL B: considerar juego de información imperfecta (los nodos no conocen las etrategias del resto
  %Utilizar el awareness obtenido de cada nodo
 
  %Maware
  %Mplay
  %[Mrep] = updateReputation2(numNodes,Mrep,Vstrategies,Maware,Vattack,reward,punish);  
  %printf("Updating reputation\n");
  [Mrep] = updateReputation22(numNodes,Mrep,Msharing,Maware,Vattack,reward,punish);  

  
%  for n=1:numNodes
%    for j=1:numNodes
%      if (j!=n)
%        if (Vaware(n)> 0)
%        %El nodo n incrementa el nivel de conocimiento (awareness) por el nodo j
%          Vrep(j) = Vrep(j) + (reward * Vrep(j));
%          if (Vrep(j) > 1) 
%            Vrep(j) = 1;
%          end
%        else
%        %El nodo n NO inrementa el nivel de conocimiento(awareness) por el nodo j
%          Vrep(j) = Vrep(j) - (punish * Vrep(j));        
%          if (Vrep(j) < 0) 
%            Vrep(j) = 0;
%          end
%        end
%      end
%    end
%  end

  
  
  Ac_rep = vertcat(Ac_rep, [vt Mrep]);
  
  %***************
  %UPDATE TRUST
  %***************
  %¿Cómo se actualiza la confianza (trust) de "node" respecto a los otros nodos "j"?
  %DE MOMENTO NO CONSIDERAMOS QUE LA CONFIANZA SE ACTUALIZA (REPRESENTA EL RIESGO DE QUE OTRA PARTE DIVULGUE MI INFORMACIÓN)
  %La siguiente forma de actualizar la confianza es lo que se debería aplicar en la reputación
  %minLimAw = 0.5; %Minimun awareness accepted for historical rounds
  %maxLimAw = 0.9;
%  for j=1:numNodes
%    if (j!=n)
%      if (Vstrategies(j)==STRATEGY_DEFECT)              
%        %Si el jugador B no coopera (no comparte info), el jugador A no recibe ningún Awareness
%        Mtrust(n,j) = Mtrust(n,j) - (punishTrust*Mtrust(n,j));
%      elseif(Vstrategies(j)==STRATEGY_COOPERATE)
%        %Si el jugador B coopera (quiere compartir)no comparte info), pueden darse dos situaciones:
%         %a) Lo que comparte B no aporta ninguna mejora de awareness: Aw = 0
%         %b) Lo que comparte B aporta algun awareness: Aw > 0. El incremento de confianza dependerá de los limites establecidos por el jugador A.
%        if (Vaware(j)>=minLimAw)
%          newTrust = Mtrust(n,j) + (rewardTrust* Mtrust(n,j));
%          if (newTrust>1) 
%            Mtrust(n,j)=1;
%          else
%            Mtrust(n,j)=newTrust;
%          end
%        end        
%      end%if STRATEGIES
%    end %if(j!=n)
%  end %for

   t = t + 1;
   
   %STOP CRITERION
   if (t>MAX_EPOCH)
    endSimulation=1;   
    printf("STOPPING BY MAX_EPOCH\n");
%   elseif ((sum(sum(Mimmun==1)))>=(rows(Mimmun)*columns(Mimmun)))
%    endSimulation=1;
%    printf("STOPPING BY EVERY NODES IMMUNIZED in t=%i\n",t);
   end
   
end%WHILE

%FOR TRACING PURPOSE: SAVE VARIABLES IN FILE
%r = strcat('cm_',params);
%save(r);

end

