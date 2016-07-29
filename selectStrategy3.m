function [Msharing] = selectStrategy3(Vattack,Vstrategies,MsharingOld,Mserv)

STRATEGY_DEFECT = 0;
STRATEGY_COOPERATE = 1;

Msharing = zeros(size(Mserv)); 
Mdep = Mserv';
 
%Calculate strategies among all nodes
for i=1:columns(Mserv)

  [deg degin degout] = degrees(Mserv);

  if (Vstrategies(i)==0)
    %Cooperate with every node in the network
    for j=1:columns(Mserv)
      if (j!=i)
        Msharing(i,j)= STRATEGY_COOPERATE;
      end
    end
  
  elseif (Vstrategies(i)==1)    
    %Random cooperation with percentage 'p' of nodes    
    p = 0.25;
    numNodesCooperate = ceil(p*columns(Mserv-1)); 
    randU = rand(1,columns(Mserv)); 
    Vcooperate = (randU(1,:)<=p);
    for j=1:columns(Vcooperate)
      if (j!=i)
        Msharing(i,j)=Vcooperate(j);
      end
    end

  elseif (Vstrategies(i)==2)
    %node i cooperates only with nodes on whom it is dependent
    for j=1:columns(Mdep)
      if ((j!=i) && (Mdep(i,j)>0))        
        Msharing(i,j)=STRATEGY_COOPERATE;        
      end
    end
  
  elseif (Vstrategies(i)==3)
    p = 0.1;%Nodes percentage with which has higher dependency.    
    [vdep idep] = sort(Mdep(i,:),'descend');
    numNodesCooperate = ceil(p*columns(Mserv-1));
    for j=1:numNodesCooperate
      if (vdep(j)>0)
        Msharing(i,idep(j))=STRATEGY_COOPERATE;
      end          
    end    
  
  elseif (Vstrategies(i)==4)
    [vserv iserv] = sort(degout,'descend');
    max_degout = vserv(1);
    for j=1:columns(vserv)
      if (vserv(j)==max_degout)
        Msharing(i,iserv(j))=STRATEGY_COOPERATE;
      end
    end
  
  elseif (Vstrategies(i)==5)
    p = 0.1;%Nodes percentage with which has higher dependency.    
    [vserv iserv] = sort(degout,'descend');
    numNodesCooperate = ceil(p*columns(Mserv-1));
    for j=1:numNodesCooperate
      if (vserv(j)>0)
        Msharing(i,iserv(j))=STRATEGY_COOPERATE;
      end          
    end    

  elseif (Vstrategies(i)==99)
    %Never Cooperate
    for j=1:columns(Mserv)
      if (j!=i)
        Msharing(i,j)= STRATEGY_DEFECT;
      end
    end
  
  end%if-cases-gameStg

end%for

end