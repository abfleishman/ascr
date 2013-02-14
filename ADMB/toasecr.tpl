
PROCEDURE_SECTION
  // Setting up variables
  int i, j;
  dvariable p, d, nzz;
  dvar_matrix p1(1,ntraps,1,nmask);
  dvar_matrix p2(1,ntraps,1,nmask);
  dvar_matrix logp1(1,ntraps,1,nmask);
  dvar_matrix logp2(1,ntraps,1,nmask);
  dvar_vector pm(1,nmask);
  dvar_vector wi1(1,ntraps);
  dvar_vector toall(1,nmask);
  // Probability of detection at any trap for each location.
  for (i = 1; i <= nmask; i++){
    p = 1;
    for (j = 1; j <= ntraps; j++){
      d = dist(j,i);
      // Flag for detection function insertion.
      p1(j,i) = //@DETFN;
      p2(j,i) = 1 - p1(j,i);
      p *= p2(j,i);
    }
    pm(i) = 1 - p + DBL_MIN;
  }
  logp1 = log(p1 + DBL_MIN);
  logp2 = log(p2 + DBL_MIN);
  dvariable L1=0;
  // Probability of capture histories for each animal.
  for (i = 1; i <= n; i++){
    wi1 = row(capt,i);
    nzz = sum(wi1);
    toall = (1-nzz)*log(sigmatoa) - ((row(toassq,i))/(2*square(sigmatoa)));
    L1 += log(sum(mfexp(log(D) + (wi1*logp1 + (1-wi1)*logp2) + toall)));
  }
  // Putting log-likelihood together.
  dvariable lambda = A*D*sum(pm);
  dvariable L2 = -n*log(D*sum(pm));
  dvariable L3 = log_density_poisson(n,lambda);
  f = -(L1 + L2 + L3);
  if (trace == 1){
    //@TRACE
  }

GLOBALS_SECTION
  #include <float.h>

REPORT_SECTION
