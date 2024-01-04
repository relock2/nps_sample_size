# Sample Size Calculator for Net Promoter Score

The Net Promoter Score is a popular business metric used to measure customer satisfaction by asking customers: "On a scale from 0 to 10, how likely are you to recommend this product/company to a friend or colleague?"

Customer responses are then categorized by their rating:

* Promoters: 9 or 10
* Passives: 7 or 8
* Detractors: 0 - 6

The Net Promoter Score is then calculated as the percentage of promoters minus the percentage of detractors.

![64020daae50d701ac16ebd7a_Net Promoter Score](https://github.com/relock2/nps_sample_size/assets/16982081/a6ca4d39-1169-4a8f-8644-051d135d209c)

A Net Promoter Score can range from +100 to -100.

Because the proportions of Promoters and Detractors are not independent (e.g. if you have 90% Promoters, you can't have more than 10% Detractors), confidence intervals for a Net Promoter Score cannot be calculated as simple proportions. This function uses the Adjusted Wald method for calculating confidence intervals as tested [here](https://arxiv.org/pdf/1601.07235.pdf) and explained [here](https://www.tlfresearch.com/news-opinion/what-is-your-nps-margin-of-error/).

Below is an example of the formula for a 95% confidence interval:

![image](https://github.com/relock2/nps_sample_size/assets/16982081/4acb54df-630c-458c-bfcf-244bef3997f7)

Users often want a confidence interval for their Net Promoter Score to fall within a given range. For example, if a company has a goal for their Net Promoter Score to be +75, they may want to know that the true score lies within 10 points of that estimate (+65 to +75). This function allows users to specify how many points in either direction they want their confidence interval to spread and receive the minimum sample size to do so. The ability to enter multiple values also lets the user see what level of confidence they can achieve if they have an idea of their estimated sample size.

![image](https://github.com/relock2/nps_sample_size/assets/16982081/ad580099-7120-4731-bbd7-b8e2a568620e)

Code to produce chart:
```
nps_example <- data.frame(promoter_proportion = seq(0.1, 0.9, by = 0.01),
                          ci.80 = nps_sample_size(m = 10, prom_prop = seq(0.1, 0.9, by = 0.01), det_prop = 0.05, population = 10000, ci = 0.8),
                          ci.95 = nps_sample_size(m = 10, prom_prop = seq(0.1, 0.9, by = 0.01), det_prop = 0.05, population = 10000, ci = 0.95),
                          ci.99 = nps_sample_size(m = 10, prom_prop = seq(0.1, 0.9, by = 0.01), det_prop = 0.05, population = 10000, ci = 0.99))
nps_example |>
  pivot_longer(!promoter_proportion, names_to = 'ci', values_to = 'min_sample_size') |>
  ggplot(aes(x = promoter_proportion, y = min_sample_size, color = ci)) +
  geom_smooth()  + 
  labs(title="Sample Size Required for 10-pt CI", y = "Sample Size", x = 'Proportion of Promoters') +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face='bold'), 
        legend.position = 'none') +
  annotate("text", x = 0.1, y = 24, label = "80%", size = 4) +
  annotate("text", x = 0.1, y = 57, label = "95%", size = 4) +
  annotate("text", x = 0.1, y = 99, label = "99%", size = 4)
```

Finally, Net Promoter Scores sometimes need to be calculated for small populations. This function automatically applies the [Finite Population Correction Factor](https://openstax.org/books/introductory-business-statistics/pages/7-4-finite-population-correction-factor) if the suggested sample size is greater than 5% of the population provided by the user.
