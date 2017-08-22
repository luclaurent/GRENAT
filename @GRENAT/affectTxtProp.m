%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function for declaring the purpose of each properties
function info=affectTxtProp()
info.type='Type of the surrogate model';
info.sampling='Coordinates of the sample points';
info.resp='Value(s) of the responses at the sample points';
info.grad='Value(s) of the gradients at the sample points';
info.samplingN='Normalized coordinates of the sample points';
info.respN='Value(s) of the normalized responses at the sample points';
info.gradN='Value(s) of the normalized gradients at the sample points';
info.nonsamplePts='Coordinates of the non-sample points';
info.nonsampleResp='Value(s) of the approximated responses calculated at the non-sample points';
info.nonsampleGrad='Value(s) of the approximated gradients calculated at the non-sample points';
info.nonsamplePtsN='Normalized coordinates of the  non-sample points';
info.nonsampleRespN='Value(s) of the normalized approximated responses calculated at the non-sample points';
info.nonsampleGradN='Value(s) of the normalized approximated gradients calculated at the non-sample points';
info.nonsampleVar='Value(s) of the variance calculated at the non-sample points';
info.nonsampleCI='Structure containing the bounds of the confidence intervals (68%, 95%, 99%)';
info.nonsampleEI='Value(s) of the expected improvment calculated at the non-sample points';
info.norm='Structure containing the normalization data';
info.normMeanS='Mean value of the sample points (vector)';
info.normStdS='Standard deviation of the sample points (vector)';
info.normMeanR='Mean value of the responses';
info.normStdR='Standard deviation of the responses';
info.err='Structure containing the values of the error criteria';
info.sampleRef='Array of the sample points used for the reference response surface';
info.respRef='Array of the responses of the reference response surface';
info.gradRef='Array of the gradients of the reference response surface';
info.confMeta='Class object (initMeta) containing information about the configuration (metamodel) (conf method for modifying it)';
info.dataTrain='Structures containing data about the training of the surrogate model';
info.confDisp='Class object (initDisp) containing information about the display (conf method for modifying it)';
info.miss='Structure Containing information about the missing data';
end
