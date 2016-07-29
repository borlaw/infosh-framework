function [Veffect] = setAttackEffect2(Vattack,VdefaultAttackEffect)

%TO-DO Entire function. At the moment return constant value

%Veffect = (round(10 * (1 ./ Vattack)) / 10) + 0.2;
Veffect = zeros(1,columns(Vattack));

for i=1:columns(Vattack)
  if (Vattack(i)>0)
    Veffect(i) = VdefaultAttackEffect(Vattack(i));
  end
end


end