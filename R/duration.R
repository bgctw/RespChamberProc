plotDurationUncertainty <- function(
	### plot the increase of uncertainty with decreaseing measurment duration
	ds
	,fRegress = c(exp=regressFluxExp, lin=regressFluxLinear, tanh=regressFluxTanh)	##<< list of functions to yield 
			##<< a single flux estimate, see details of \code{\link{calcClosedChamberFlux}}
	,...	##<< further arguments to \code{\link{calcClosedChamberFlux}}
	,nDur = 20		##<< number of durations to check
	,maxSdFlux = 1	##<< maxium allowed standard deviation of flux in [mumol / s]
){
	times <- ds$TIMESTAMP
	times0 <- as.numeric(times) - as.numeric(times[1])
	resFit0 <- calcClosedChamberFlux(ds,...)
	resFit0$stat
	durations <- seq( max(60,resFit0$stat["tLag"]), max(times0), length.out=nDur+1)
	duration <- durations[1]
	#plot( CO2_dry ~ times0, ds)
	resFitsO <- lapply( durations[-c(nDur+1) ], function(duration){
				dss <- subset(ds, times0 <= duration )
				times0s <- times0[times0 <= duration]
				resFit <- calcClosedChamberFlux(dss, tLagFixed=resFit0$stat["tLag"], fRegress=fRegress[resFit0$stat["iFRegress"]],...) 
				#plot( CO2_dry ~ times0s, dss)
				#lines( fitted(resFit$model) ~ times0s[times0s >= resFit0$stat["tLag"]], col="red")
				c(resFit, duration = max(times0s) )
			})
	resFits <- c(resFitsO, list(c(resFit0,duration=max(times0)) ))
	#resFit <- resFitsO[[1]]
	durationsR <- sapply( resFits, function(resFit){
				resFit$duration
			}) 
	tmp2 <- cbind( duration=durationsR, t(sapply( resFits, function(resFit){resFit$stat}))) 
	iMinTime <- min(which( tmp2[,"sdFlux"] < maxSdFlux ))
	minDuration <- tmp2[iMinTime,]
	plot( sdFlux ~ duration, tmp2, xlab="Duration of measurement (s)" , ylab="sd(fluxEstimate)")
	abline(h = maxSdFlux, col="grey", lty="dashed" )
	abline(v = minDuration["duration"], , col="grey", lty="dashed" )
	#plot( flux ~ duration, tmp2 )
	#
	##value<< result of \code{\link{calcClosedChamberFlux}} for the minimum duration, with addition components 
	c(resFits[[ iMinTime ]][1:2]
		, duration=as.numeric(minDuration[1])	##<< minimum duration in seconds, with sdFlux < maxSdFlux
		, statAll= list(tmp2)					##<< component stat of the fits for each duration
	)
}
attr(plotDurationUncertainty,"ex") <- function(){
	data(chamberLoggerEx2)
	ds <- subset(chamberLoggerEx2, iChunk==99)	# very strong (and therefore precise) uptake
	#plot( CO2_dry ~ TIMESTAMP, ds )
	resDur <- plotDurationUncertainty( ds, colTemp="AirTemp", volume = 0.6*0.6*0.6, maxSdFlux = 0.8 )
	resDur$duration
	#plot( flux ~ duration, resDur$statAll )
	#plot( sdFlux ~ duration, resDur$statAll )
}