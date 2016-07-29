
function [] = runSimsParam2(scenario,numSims,fixedAttacks)
  
dir = "resim/";
subdir= "sims30/";

%File with Attack Matrix in previous scenario simulation
%IMPORTANT: FILE TO LOAD MUST HAVE >= NUM SIMULATIONS THAN THIS  
%load "./resim/vmattackA.mat" vmattack;%vmattack is a CellArray
load(fixedAttacks,"vmattack");
  
for i=1:numSims

  [acia, arep, aaw, autil, astg, ash, Mattack, Mimmun, MAX_EPOCH] = cybermodelParam2Sim(scenario,vmattack{1,i});
  
  save(strcat("./",dir,subdir,"res",num2str(numSims),"sim",num2str(i),"_",scenario));
  
end%for

end%function
