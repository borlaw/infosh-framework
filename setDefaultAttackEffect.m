function [VdefaultAttackEffect] = setDefaultAttackEffect(NUM_ATTACKS)

%Mean (b)
mu = 0.4

%Standard deviation (a)
sigma = 0.2

%NORMAL DISTRIBUTION
%formula y = a * randn(vector) + b;
VdefaultAttackEffect = sigma.*randn(NUM_ATTACKS,1) + mu;

%VdefaultAttackEffect10Nodes = [
% 0.4112149585038424
% 0.3834668199531734
% 0.7320165157318116
% 0.6352339446544648
% 0.720891110599041
% 0.2957894772291184
% 0.3720859121531248
% 0.3354445307515562
% 0.269649888202548
%];
%
%VdefaultAttackEffect100Nodes = [
%];
%
%VdefaultAttackEffect = VdefaultAttackEffect10Nodes

end