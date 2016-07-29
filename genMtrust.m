function [Mtrust] = genMtrust(numNodes,opt,val)
%'opt' establece dos formas de generar la matriz de confianza entre nodos
%0: todos los nodos con la misma confianza 
%1: valores random

Mtrust = ones(numNodes,numNodes);

for i=1:numNodes
  for j=1:numNodes
    if (i!=j)
      if (opt==0)%Todos los nodos con mismo valor de confianza 'val'
        Mtrust(i,j)=val;
      elseif (opt==1)%random trust generation. Uniform distribution
        Mtrust(i,j)=round(rand() * 100) / 100;
      end
    end    
  end          
end

end

