function [Vstrategies] = setVstrategies(numNodes,gameStgLocal,stgEpoch,gameStg,VstrategiesOld)
 %New Vstrategies are set up only if local behaviour gameStgLocal=1 and param stgEpoch=1;

 Vstrategies = VstrategiesOld;
 
 if (gameStgLocal==1) && (stgEpoch==1) 
    %TO-DO 
 end
  

end