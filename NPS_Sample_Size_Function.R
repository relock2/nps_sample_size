#' Calculate minimum required sample size for CI and width for Net Promoter Score
#'
#' Using assumptions and constraints provided by the user, this function calculates
#' the minimum sample size required to achieve a given confidence interval using the
#' adjusted Wald method at a given width for a Net Promoter Score on a scale of 
#' -100 to 100. Applies Finite Population Correction automatically if the
#' recommended sample size is greater than 5% of the provided population.
#'
#' @param m: The desired width of the confidence interval (z * margin of error)
#' @param prom_prop: The estimated proportion of promoters in the population
#' @param det_prop: The estimated proportion of detractors in the population
#' @param population: (Optional) The estimated population size
#' @param ci: The desired confidence interval on a scale of 0 to 1 (e.g. 0.95 = 95$ CI)
#'
#' @return A single value or vector of sample sizes required to achieve the confidence interval.
#'
#' @examples
#' nps_sample_size <- function(m = 10, prom_prop = 0.8, det_prop = 0.15, 
#'                             population = 250, ci = 0.95)
#' @export


nps_sample_size <- function(m, prom_prop, det_prop, population = 1000000, ci = 0.95) {

  # Check for missing values  
  if (missing(m)) stop("Argument `m` is required. This is how many points wide you want your Net Promoter Score margin of error to be.")
  if (missing(prom_prop))   stop("Argument `prom_prop` is required. This is the estimated proportion of Promoters.")
  if (missing(det_prop))   stop("Argument `det_prop` is required. This is the estimated proportion of Detractors.")
  if (any(prom_prop + det_prop > 1))   stop("Invalid proportions of Promoters and Detractors. Combined proportions cannot exceed 100%.")

  # Check data types
  if (!is.numeric(m)) stop("Argument `m` must be numeric")
  if (!is.numeric(prom_prop)) stop("Argument `prom_prop` must be numeric")
  if (!is.numeric(det_prop)) stop("Argument `det_prop` must be numeric")
  if (!is.numeric(population)) stop("Argument `population` must be numeric")
  
  # Check for invalid inputs
  if (any(m < 0 | prom_prop < 0 | det_prop < 0 | ci < 0)) stop("Input values must be positive numbers.")
  if (any(population < 2)) stop('Population must be at least 2.')
  if (any(ci < 0.5) | any(ci > 0.999)) stop("Confidence interval (ci) must be between 0.5 and 0.999.")

  # Find the maximum length among all parameters
  max_length <- max(length(m), length(prom_prop), length(det_prop), length(population), length(ci))
  
  # Repeat each parameter to match the max_length
  m <- rep(m, length.out = max_length)
  prom_prop <- rep(prom_prop, length.out = max_length)
  det_prop <- rep(det_prop, length.out = max_length)
  population <- rep(population, length.out = max_length)
  ci <- rep(ci, length.out = max_length)
  
  # Calculations
  
  z <- 1 - (1-ci) / 2
  
  n_values <- numeric(length(prom_prop))
  
  for (i in seq_along(prom_prop)) {
    objective_function <- function(n) {
                      # Use t distribution if sample size < 30
      calculated_m <- ifelse(n < 30, qt(z[i],df= n-1) , round(qnorm(z[i]),2)) * sqrt((((prom_prop[i] * n) + 3/4) / (n + 3) + ((det_prop[i] * n) + 3/4) / (n + 3) -  # If sample is greater than 5% of population, then apply Finite Population Correction
                                     (((prom_prop[i] * n) + 3/4) / (n + 3) - ((det_prop[i] * n) + 3/4) / (n + 3))^2) / (n + 3)) * 100 * ifelse((n / population[i]) > 0.05, sqrt((population[i] - n)/(population[i] - 1)), 1)
      return(calculated_m - m[i])
    }
    
    # Use uniroot to find the zero of the objective function, hence the sample size n
    n_estimate <- uniroot(objective_function, lower = 2, upper = population[i])$root
    # Round results up to nearest integer
    n_values[i] <- ceiling(n_estimate)
  }
  return(n_values)
    
  }
