# GTM Opportunities & Recommendations

Based on the data product built from Owner.com's Salesforce and finance data (Jan–Jun 2024), two high-impact opportunities stand out for driving the GTM function toward 2–3x growth while improving CAC:LTV ratio.

---

## Opportunity 1: Close the "No Demo Held" Funnel Leak

### The Problem

**605 out of 1,762 closed-lost opportunities (34.3%) were lost because a demo was never held.** This is the single largest lost reason — larger than Price (159), POS Integration (100), Lack of Urgency (186), and Missing Features (69) combined.

These are not unqualified prospects. They had already:
- Been generated as leads (either via inbound form submission or BDR cold outreach)
- Been qualified and converted into a sales opportunity
- Had a demo scheduled in most cases

Yet the most critical conversion event — the actual demo with an AE — never took place.

### The Sizing

Using the data product's funnel metrics:

| Metric | Value |
|---|---|
| Total closed-lost opportunities | 1,762 |
| Lost due to "No Demo Held" | 605 (34.3%) |
| Current win rate (among demo-held) | ~26% |
| Estimated avg annual LTV per won deal | ~$8,500–$9,500 |

If we could hold demos for even **half** of these (302 prospects) and maintain the current ~26% win rate:

```
302 recovered demos × 26% win rate ≈ 79 additional wins
79 wins × ~$9,000 avg annual LTV ≈ $711,000 in annual revenue
```

This is **pure bottom-of-funnel efficiency** — no additional ad spend, no new hires, no new leads needed. The CAC for these recovered deals is effectively $0 of incremental cost, which directly improves the CAC:LTV ratio.

### Root Causes to Investigate

The data suggests several patterns worth exploring:

1. **Scheduling delays**: How much time elapses between demo set and demo time? Long gaps increase no-show risk.
2. **Follow-up cadence**: Are SDRs/BDRs confirming and re-confirming demos? The `sales_call_count` and `sales_text_count` fields in the leads table can reveal whether reps are doing enough follow-up before scheduled demos.
3. **Same-day vs. future demos**: Opportunities where `demo_set_date` ≈ `demo_time` (same-day scheduling) likely have higher show rates. This can be validated with the `days_to_demo` field.
4. **Channel differences**: Do inbound leads (warm, self-qualified) show up to demos at higher rates than outbound leads (cold-called)?

### Recommended Actions

1. **Automated confirmation cadence**: Implement a 3-touch confirmation sequence (email at booking, SMS 24h before, SMS 1h before) for every scheduled demo.
2. **Same-day demo push**: Prioritize scheduling demos on the same call when possible. Data shows prospects cool off quickly.
3. **Rapid reschedule workflow**: When a demo is missed, trigger an immediate outreach sequence (call + text within 1 hour) to reschedule rather than letting the opportunity go stale.
4. **Tracking metric**: Add "Demo Show Rate" (demos held / demos set) as a primary KPI in the `mart__gtm_unit_economics` model. Currently, this rate appears to be around 65–70%, leaving significant room for improvement.

---

## Opportunity 2: Use Channel Unit Economics to Allocate for 2–3x Growth

### The Problem

Owner.com needs to **2–3x revenue in the next year**, which requires scaling lead generation significantly. But scaling blindly — doubling ad spend or doubling the BDR team — without understanding channel-level unit economics would be inefficient and could degrade CAC:LTV.

The data product surfaces the cost structure:

| Cost Component | 6-Month Total (Jan–Jun 2024) |
|---|---|
| Advertising (inbound) | ~$363,500 |
| Inbound sales team (SDR) | ~$248,900 |
| Outbound sales team (BDR) | ~$270,500 |
| **Total inbound cost** | **~$612,400** |
| **Total outbound cost** | **~$270,500** |

### The Scaling Question

Each channel has a fundamentally different cost structure and scaling dynamic:

**Inbound (Paid Ads → SDR → AE Demo)**
- High fixed cost (ad platforms) + variable labor (SDR salaries)
- Can scale by increasing ad spend — but CPAs (cost per acquisition) tend to increase at higher spend levels as you exhaust high-intent audiences
- Prospects are warm and self-qualified → likely higher conversion rates
- Represented by ~42% of leads (those with form submissions)

**Outbound (BDR Cold Call → AE Demo)**
- Almost entirely labor cost (BDR salaries)
- Scales linearly with headcount — adding 1 BDR adds predictable capacity
- Prospects are cold → likely lower conversion rates but BizOps can target high-value prospects
- Represented by ~58% of leads (no form submission)

### What the Data Product Reveals

The `mart__channel_performance` model computes the full funnel conversion rates and unit economics by channel, enabling comparisons like:

| Metric | Query from Data Product |
|---|---|
| Lead → Opportunity conversion rate by channel | `lead_to_opp_rate_pct` |
| Demo show rate by channel | `demo_set_to_held_rate_pct` |
| Win rate by channel | `win_rate_pct` |
| Average LTV of won deals by channel | `avg_ltv_won_deals` |
| CAC by channel (6-month) | `cac_6mo` |
| LTV:CAC ratio by channel | `ltv_to_cac_ratio_6mo` |

### A Critical Data Gap

**77% of opportunities have no explicit channel attribution** (`how_did_you_hear_about_us` is empty). The data product resolves this using lead-level inference (form submission = inbound, no form = outbound), but this is a heuristic.

Improving channel attribution is itself a high-ROI action:
- Make `how_did_you_hear_about_us` a **required field** on opportunity creation in Salesforce
- Add UTM tracking to link ad platform spend to specific leads
- This enables precise CAC:LTV by channel, by campaign, even by ad creative

### Recommended Actions

1. **Run the `mart__channel_performance` model** and compare LTV:CAC by channel. The channel with the higher ratio gets incremental budget.
2. **Model diminishing returns on inbound**: Plot monthly ad spend vs. inbound deals closed to identify the efficiency curve. If CPA is still flat or declining, there's room to scale.
3. **Test outbound expansion**: If outbound shows a favorable CAC:LTV ratio, pilot adding 2–3 BDRs and measure incremental deal volume. Outbound's advantage is targeting — BizOps can focus on restaurants with high `predicted_sales_with_owner`, optimizing for LTV.
4. **Fix attribution tracking**: Make channel a required field. The data product is built to immediately incorporate better attribution as it becomes available (the `resolved_channel` logic uses opportunity-level data first, then falls back to lead inference).

---

## Summary

| Opportunity | Impact | Effort | Primary Goal |
|---|---|---|---|
| Fix "No Demo Held" leak | ~$711K annual revenue, improved CAC:LTV | Low (process + tooling) | Improve CAC:LTV ratio |
| Channel unit economics for scaling | Data-driven 2–3x growth path | Medium (analysis + investment) | Scale 2–3x |

**Opportunity 1** is the quick win — it improves economics with no incremental spend. **Opportunity 2** is the strategic lever — it tells you _where_ to invest to grow 2–3x most efficiently.

The `mart__gtm_unit_economics` and `mart__channel_performance` models provide the ongoing SSOT to track both initiatives over time.
