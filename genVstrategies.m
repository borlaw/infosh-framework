function [Vstrategies] = genVstrategies(numNodes,randomVstrategies,gameStgLocal,gameStg,defaultVstrategies)

  Vstrategies = zeros(1,numNodes);  
  
  if (gameStgLocal==0)
    %That is, behaviour is global
    for i=1:numNodes
      Vstrategies(i)=gameStg;
    end
  
  else
    if (randomVstrategies==0)    
      Vstrategies = defaultVstrategies;    
    elseif(randomVstrategies==1)    
      %Same case as gameStgLocal=0. Every node initialize with gameStg
      for i=1:numNodes
        Vstrategies(i)=gameStg;
      end       
    elseif(randomVstrategies==2)
      for i=1:numNodes
        %Vstrategies(i)=round(randi([0,60])/10)
        Vstrategies(i)=round(randi([20,60])/10)
      end
    end  
  end
end