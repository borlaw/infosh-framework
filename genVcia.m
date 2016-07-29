function [Vcia] = genVcia(numNodes,opt,val)
%'opt' establece dos formas de generar la matriz de confianza entre nodos
%0: todos los nodos con el mismo cia
%1: valores random

Vcia = zeros(1,numNodes);

for i=1:numNodes
  if (opt==0)
    Vcia(i)=val;
  else (opt==1)
    Vcia(i)=round(rand() * 100) / 100;
  end
end

end