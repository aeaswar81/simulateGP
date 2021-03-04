#' Get summary statistics in simple linear regression
#'
#' @param y Vector of dependent variable
#' @param x Vector of independent variable
#'
#' @export
#' @return List
fast_assoc <- function(y, x)
{
	index <- is.finite(y) & is.finite(x)
	n <- sum(index)
	y <- y[index]
	x <- x[index]
	vx <- var(x)
	bhat <- stats::cov(y, x) / vx
	ahat <- mean(y) - bhat * mean(x)
	# fitted <- ahat + x * bhat
	# residuals <- y - fitted
	# SSR <- sum((residuals - mean(residuals))^2)
	# SSF <- sum((fitted - mean(fitted))^2)

	rsq <- (bhat * vx)^2 / (vx * var(y))
	fval <- rsq * (n-2) / (1-rsq)
	tval <- sqrt(fval)
	se <- abs(bhat / tval)

	# Fval <- (SSF) / (SSR/(n-2))
	# pval <- pf(Fval, 1, n-2, lowe=F)
	p <- stats::pf(fval, 1, n-2, lower.tail=FALSE)
	return(list(
		ahat=ahat, bhat=bhat, se=se, fval=fval, pval=p, n=n
	))
}


#' Perform association of many SNPs against phenotype
#'
#' @param y Vector of phenotypes
#' @param g Matrix of genotypes
#'
#' @export
#' @return Data frame
gwas <- function(y, g)
{
	out <- matrix(0, ncol(g), 6)
	for(i in 1:ncol(g))
	{
		o <- fast_assoc(y, g[,i])
		out[i, ] <- unlist(o)
	}
	out <- dplyr::as_tibble(out)
	names(out) <- names(o)
	out$snp <- 1:ncol(g)
	return(out)
}

#' Get effs for two traits and make dat format
#'
#' @param x Vector of exposure phenotype
#' @param y Vector of outcome phenotype
#' @param g Matrix of genotypes
#' @param xname xname
#' @param yname yname
#'
#' @export
#' @return Data frame
get_effs <- function(x, y, g, xname="X", yname="Y")
{
	gwasx <- gwas(x, g)
	gwasy <- gwas(y, g)
	return(merge_exp_out(gwasx, gwasy, xname, yname))
}
