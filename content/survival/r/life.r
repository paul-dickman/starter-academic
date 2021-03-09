rs.surv.lt <- 
function (formula = formula(data), data = parent.frame(), ratetable = survexp.us, 
    na.action, fin.date, method = "pohar-perme", conf.type = "log", 
    conf.int = 0.95,int) 
{
    call <- match.call()
    rform <- rformulate(formula, data, ratetable, na.action,int)		#get the data ready
    data <- rform$data
    
    l.int <- length(int)
    dint <- diff(int)
        fk <- (attributes(rform$ratetable)$factor != 1)
    nfk <- length(attributes(rform$ratetable)$dimid)				#number of demographic covariates
 
    matx<- NULL
    sp <- obs <- obsw <- 1
    meanLambda <- meanLambdaw <- meanLambdae <- 0
    spit <- rep(1,nrow(rform$data))
    for(jt in 1:(length(int)-1)){
       	inx <- rform$Y>=365.241*int[jt]
    	ntot <- sum(inx)
    	inx.dead <- (rform$Y>=365.241*int[jt]&rform$Y<365.241*int[jt+1]&rform$status)
    	ndead <- sum(inx.dead)
    	inx.cens <- (rform$Y>=365.241*int[jt]&rform$Y<365.241*int[jt+1]&rform$status==0)
   	ncens <- sum(inx.cens)
   	spi <- srvxp.fit(data[, 4:(nfk + 3)], rep(dint[jt]*365.241,length(inx)), rform$ratetable)
   	Lambda <- -log(spi)
   	spit <- spit*spi
   	ndeadw <- sum(inx.dead/spit)
   	ncensw <- sum(inx.cens/spit)
   	ntotw <- sum(inx/spit)
   	sp <- mean(spi[inx])*sp
   	meanLambda <- meanLambda + sum(inx*Lambda)/sum(inx)
   	meanLambdaw <- meanLambdaw+sum(inx/spit*Lambda)/sum(inx/spit)
   	meanLambdae <- meanLambdae + sum(spit*Lambda)/sum(spit)
   	sp <- exp(-meanLambda)
   	spw <- exp(-meanLambdaw)
   	spe <- exp(-meanLambdae)
   	obs <- (1- ndead/(ntot - ncens/2))*obs
   	obsw <- (1- ndeadw/(ntotw - ncensw/2))*obsw
  	vector <- c(int[jt],int[jt+1],ntot,ndead,ncens,sp,obs, obs/sp,obsw/spw,obs/spe)
  		
 	matx <- rbind(matx,vector)
 	
 	data[, 4:(nfk + 3)] <- data[, 4:(nfk + 3)] + matrix(fk *dint[jt]*365.241 , ncol = ncol(data), byrow = TRUE, nrow = nrow(data))
    }
    row.names(matx) <- NULL
    matx <- as.data.frame(matx)
    names(matx) <- c("start","stop","total","dead","censored","expected","observed","ede2","mpp","ede")
    matx
    
    
}

