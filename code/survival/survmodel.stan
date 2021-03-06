
functions {
  real ourmodel_lpdf(real t, real age, real agerate, real k, real r20 ){
    return( (-(365*r20*exp((agerate*k*t)/365+age*agerate-20*agerate))/(agerate*k))
	    +(agerate*k*t)/365+log(r20)+(365*exp(age*agerate-20*agerate)*r20)/(agerate*k)
	    +age*agerate-20*agerate);
    
  }
  real ourmodel_lccdf(real t, real age, real agerate, real k, real r20){
    return(-r20*((365*exp((agerate*k*t)/365+age*agerate-20*agerate))/(agerate*k)
            -(365*exp(age*agerate-20*agerate))/(agerate*k)));
    
  }
}


data{
  int Np;
  int Nt;
  int Nc;
  int age[Np];
  int patient[Np];
  int tissue[Np];
  int tclass[Np];
  real tevent[Np];
  int eventtype[Np];
  real menccdf[101];
  real womccdf[101];
  int gender[Np];
}

parameters{
  real<lower=0.0> r20[2];
  real<lower=0.0> k[Nt,Nc];
  real<lower=0.0> ktis[Nt];
  real<lower=0.0> agerate[2];
}

model{
  agerate ~ gamma(2.0,1.0/1.0);
  r20 ~ gamma(1.5,0.5/1.0);
  for(tis in 1:Nt){
    ktis[tis] ~ gamma(1.2,0.2/1.0);
    for( cl in 1:Nc){
      k[tis,cl] ~ gamma(3.5,2.5/1.0);
    }
  }

  // calibrate the age specific risk rate to CDC published life tables
  log(womccdf[71]) ~ normal(ourmodel_lccdf(70*365 | 0,agerate[1]*.05,1,r20[1]*1e-5),log(1.01));
  log(menccdf[71]) ~ normal(ourmodel_lccdf(70*365 | 0,agerate[2]*.05,1,r20[2]*1e-5),log(1.01));
  log(womccdf[76]) ~ normal(ourmodel_lccdf(75*365 | 0,agerate[1]*.05,1,r20[1]*1e-5),log(1.01));
  log(menccdf[76]) ~ normal(ourmodel_lccdf(75*365 | 0,agerate[2]*.05,1,r20[2]*1e-5),log(1.01));  
  log(womccdf[81]) ~ normal(ourmodel_lccdf(80*365 | 0,agerate[1]*.05,1,r20[1]*1e-5),log(1.01));
  log(menccdf[81]) ~ normal(ourmodel_lccdf(80*365 | 0,agerate[2]*.05,1,r20[2]*1e-5),log(1.01));
  log(womccdf[86]) ~ normal(ourmodel_lccdf(85*365 | 0,agerate[1]*.05,1,r20[1]*1e-5),log(1.01));
  log(menccdf[86]) ~ normal(ourmodel_lccdf(85*365 | 0,agerate[2]*.05,1,r20[2]*1e-5),log(1.01));  
  log(womccdf[91]) ~ normal(ourmodel_lccdf(90*365 | 0,agerate[1]*.05,1,r20[1]*1e-5),log(1.01));
  log(menccdf[91]) ~ normal(ourmodel_lccdf(90*365 | 0,agerate[2]*.05,1,r20[2]*1e-5),log(1.01));  
  log(womccdf[96]) ~ normal(ourmodel_lccdf(95*365 | 0,agerate[1]*.05,1,r20[1]*1e-5),log(1.01));
  log(menccdf[96]) ~ normal(ourmodel_lccdf(95*365 | 0,agerate[2]*.05,1,r20[2]*1e-5),log(1.01));  
  
  
  for(i in 1:Np){
    int tis = tissue[i];
    int cl = tclass[i];
    if(eventtype[i] == 1){
      target += ourmodel_lpdf(tevent[i]| age[i],agerate[gender[i]] * 0.05 ,ktis[tis]*k[tis,cl],r20[gender[i]] * 1e-5);
    }else{
      target += ourmodel_lccdf(tevent[i]| age[i],agerate[gender[i]] * 0.05 ,ktis[tis]*k[tis,cl],r20[gender[i]] * 1e-5);
    }
  }
}



