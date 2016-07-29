function [VciaNew, VstatesNew, VpropagationNew] = propagateAttack2(Mserv, MservInd, Vstates, Vpropagation, VattackEffect, Vcia, opt)
  %STATES
  STATE_OPERATIVE = 0;
  STATE_ATTACKED  = 1;
  STATE_IMPACTED  = 2;

  NO_SPREAD = 0;
  SPREAD = 1;

  VciaNew= Vcia;
  VstatesNew = Vstates;
  VpropagationNew = Vpropagation;
  
  
  %----opt----
  %opt=0 --> propagate to neighbour for each epoch
  %opt=1 --> propagate to every node at the time when cyber attack is received
  %----opt----
    
  if (opt==0)
    for p=1:columns(Vpropagation)
      %printf("Propagation:p=%d\n",p);
      if (Vpropagation(p)==SPREAD) %spread effects on neighbours nodes marked in Vpropagation
        for j=1:columns(Mserv)
          %printf("Propagation:j=%d\n",j);
          if ((Mserv(p,j)>0) && (Vstates(j)==STATE_OPERATIVE))
             %Update CIA value of neighbour node         
             pNewcia = Vcia(j) - abs((Vcia(j) * (VattackEffect(p) * Mserv(p,j))));                  
             %printf("Propagation:new CIA for j=%d is %d\n",j,pNewcia);
             VciaNew(j) = pNewcia;
             
             %Update Vstates for next epoch
             VstatesNew(j) = STATE_IMPACTED;
             
             %Update Vpropagation for next epoch
             VpropagationNew(j) = SPREAD;

          end
        end
        VpropagationNew(p) == NO_SPREAD;
      end
    end
  elseif (opt==1)
    for p=1:columns(Vpropagation)
      if (Vpropagation(p)==SPREAD)
        for j=1:columns(MservInd)
          pNewcia = Vcia(j) - abs((Vcia(j)* (VattackEffect(p) * MservInd(p,j))));
          VciaNew(j) = pNewcia;         
          if (MservInd(p,j)>0)
            VStatesNew(j) = STATE_IMPACTED;            
        end        
      end
    end

  end

end