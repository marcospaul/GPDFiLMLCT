
function value=LMLTEST(GP_opt,GP_opt_plus)
value=GP_LMLG_FN(GP_opt,[GP_opt.meanpar,GP_opt.covpar,GP_opt.noisepar]) - GP_LMLG_FN(GP_opt_plus,[GP_opt_plus.meanpar,GP_opt_plus.covpar,GP_opt_plus.noisepar]);
