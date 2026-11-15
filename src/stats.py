"""Hypothesis tests for comparing experiment arms using summary statistics."""

from math import sqrt
from scipy import stats
import pandas as pd

def diff_in_proportions(
    successes_t: float, n_t: float, successes_c: float, n_c: float, alpha: float = 0.05
) -> dict:
    """Compare two proportions (treatment minus control) with a two-sided z-test.

    The test statistic uses the pooled standard error, which is correct under the
    null hypothesis that both proportions are equal. The confidence interval uses
    the unpooled standard error, because it should not assume the null is true.
    """
    p_t = successes_t / n_t
    p_c = successes_c / n_c
    diff = p_t - p_c

    # Hypothesis test under H0: p_t == p_c
    p_pool = (successes_t + successes_c) / (n_t + n_c)
    se_pooled = sqrt(p_pool * (1 - p_pool) * (1 / n_t + 1 / n_c))
    z_stat = diff / se_pooled
    p_value = 2 * stats.norm.sf(abs(z_stat))

    # Confidence interval for the difference
    se_unpooled = sqrt(p_t * (1 - p_t) / n_t + p_c * (1 - p_c) / n_c)
    z_crit = stats.norm.ppf(1 - alpha / 2)

    return {
        "treatment_value": p_t,
        "control_value": p_c,
        "diff": diff,
        "ci_low": diff - z_crit * se_unpooled,
        "ci_high": diff + z_crit * se_unpooled,
        "relative_lift": diff / p_c,
        "test_statistic": z_stat,
        "p_value": p_value,
    }


def diff_in_means_welch(
    mean_t: float, var_t: float, n_t: float,
    mean_c: float, var_c: float, n_c: float,
    alpha: float = 0.05,
) -> dict:
    """Compare two means (treatment minus control) with Welch's t-test.

    Welch's test does not assume equal variances. Spend is highly skewed, but with
    large samples the sampling distribution of the mean is approximately normal
    (central limit theorem), so the t-test remains valid.
    """
    diff = mean_t - mean_c
    se = sqrt(var_t / n_t + var_c / n_c)

    # Welch-Satterthwaite approximation for the degrees of freedom
    df = (var_t / n_t + var_c / n_c) ** 2 / (
        (var_t / n_t) ** 2 / (n_t - 1) + (var_c / n_c) ** 2 / (n_c - 1)
    )

    t_stat = diff / se
    p_value = 2 * stats.t.sf(abs(t_stat), df)
    t_crit = stats.t.ppf(1 - alpha / 2, df)

    return {
        "treatment_value": mean_t,
        "control_value": mean_c,
        "diff": diff,
        "ci_low": diff - t_crit * se,
        "ci_high": diff + t_crit * se,
        "relative_lift": diff / mean_c,
        "test_statistic": t_stat,
        "p_value": p_value,
    }

def compare_arms(
    summary: pd.DataFrame, treatment: str, control: str, alpha: float = 0.05
) -> pd.DataFrame:
    """Compare two arms on visit rate, conversion rate and spend per customer.

    `summary` must be indexed by arm and contain the columns returned by
    sql/10_arm_summary_stats.sql: n, visits, conversions, spend_mean, spend_var.
    """
    t = summary.loc[treatment]
    c = summary.loc[control]

    results = {
        "visit": diff_in_proportions(t["visits"], t["n"], c["visits"], c["n"], alpha),
        "conversion": diff_in_proportions(
            t["conversions"], t["n"], c["conversions"], c["n"], alpha
        ),
        "spend": diff_in_means_welch(
            t["spend_mean"], t["spend_var"], t["n"],
            c["spend_mean"], c["spend_var"], c["n"],
            alpha,
        ),
    }

    df = pd.DataFrame(results).T.rename_axis("metric").reset_index()
    df.insert(0, "comparison", f"{treatment} vs {control}")
    return df