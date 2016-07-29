function [Mrep] = updateReputation22(numNodes,Mrep,Msharing,Maware,Vattack,reward,punish)

STRATEGY_DEFECT = 0;
STRATEGY_COOPERATE = 1;
  
  for n=1:numNodes    
    %if (Vattack(n)>0)
    
      for j=1:numNodes

        if (j!=n)
        
          if (Maware(j,n) > 0)
            %El nodo 'n' aporta a j al cooperar
            Mrep(n,j) = Mrep(n,j) + (reward * Mrep(n,j));
            if (Mrep(n,j) > 1) 
              Mrep(n,j)=1;          
            end
            
          else
            if (Msharing(n,j)==STRATEGY_COOPERATE)
              %El nodo 'n' no aporta nada nuevo a j pero intenta cooperar
              Mrep(n,j) = Mrep(n,j) - ((punish * Mrep(n,j)/2));
            elseif (Msharing(n,j)==STRATEGY_DEFECT)
              %El nodo 'n' no aport anda porque no coopera
              Mrep(n,j) = Mrep(n,j) - (punish * Mrep(n,j));
            
            end
            
            %Si el valor en Msharing es -1, no hay STRATEGY_COOPERATE(=1) ni STRATEGY_DEFECT(=0) es porque los nodos no ha jugado entre ellos
            %Por lo tanto no hay que actualizar el valor de reputación entre ellos.
            
            if (Mrep(n,j)<0) 
              Mrep(n,j)=0;
            end
            
          end%if-Maware
          
        end%if-j<>n
        
      end%for-j
      
    %end%if-Vattack
    
  end%for-n

end