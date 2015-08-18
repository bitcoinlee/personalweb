setwd("C:/Users/sotiris.pa/Dropbox/Programming/1.Freelancer/6.R to SAS Conversion Additional Bits of Statistical Computation")

df_data <- read.csv("Sample_Tested.csv", stringsAsFactors = FALSE)
df_data$factor8 <- as.numeric(df_data$factor8)
df_data$factor9 <- as.numeric(df_data$factor9)
str(df_data)
head(df_data)

df_data <- na.omit(df_data)

for(i in 3:12){
  if(sd(df_data[, i])==0){
    df_data <- df_data[, -i]
  }else{
    df_data[, i] <- scale(df_data[, i])    
  }
}

summary(df_data)





df_data <- df_data[with(df_data, order(raceId, rank)), ]

df_data$frank <- ifelse(df_data$rank == 1, 1, 0)
fit <- glm(frank ~ factor1 + factor2 + factor3 + factor4 + factor5 + factor6 + factor7 + factor8 + factor9, 
           family = binomial(),
           data = df_data)
summary(fit)


f <- function(beta = rep(1, 11), 
              df_data){
  d_win <- subset(df_data, rank == 1)
  
  sum_all <- exp(cbind(1, as.matrix(df_data[, 3:11])) %*% matrix(beta, ncol=1))
  sum_all <- sum(log(unlist(by(sum_all, list(df_data$raceId), sum))))
  
  sum_win <- sum(cbind(1, as.matrix(d_win  [, 3:11])) %*% matrix(beta, ncol=1))
  return(sum_win - sum_all)
}


n <- 10

beta0 <- c(1, 1, 1, 1, 1,
          1, 1, 1, 1, 1)
beta0 <- coef(fit)/sum(coef(fit))

d_by <- 0.01

for(j in 1:100){
  out_delta <- rep(0, n)
  for(i in 1:n){
    beta1 = beta0
    beta1[i] <- beta1[i] + d_by*(n-1)
    beta1[-i] <- beta1[-i] - d_by
    # cat(beta1, "\n")
    # cat(i, f(beta1, df_data) - f(beta0, df_data), "\n")
    out_delta[i] <- f(beta1, df_data) - f(beta0, df_data)
  }
  if(max(out_delta)>0){
    i <- which.max(out_delta)
    beta1 = beta0
    beta1[i] <- beta1[i] + d_by*(n-1)
    beta1[-i] <- beta1[-i] - d_by
    beta0 = beta1
    cat(j, "th update", i, ":", f(beta0, df_data), "\n")
  }else{
    cat(j, "th degrade", "\n")
    break
  }
}

names(beta0) <- names(coef(fit))

cat("the optimized coef is:", "\n")
print(beta0)

