**Case Study: GTM Analytics Engineer**

### **Problem**

At the core of any business is the basic question: “How can I reliably and scalably put money in and get more money out?”.

Through intentional design and good fortune, Owner (Owner.com) has a strong foundational GTM system and CAC:LTV ratio. We're looking to capitalize on those tailwinds and grow 2-3x in the next year, while continuing to improve our fundamentals in the GTM space.

### **Context**

The current sales process is primarily composed of 2 channels: Inbound and Outbound.

Inbound traffic is driven through paid advertisements on facebook and google. After a prospect submits an interest form on Owner.com, a lead is created in salesforce and an SDR (Sales Development Rep) on our team reaches out to schedule a demo with the prospect. At the point of the demo, an AE meets with the prospect to convince them to work with Owner (Owner.com) and takes over the sales process to try and convince them to use Owner (Owner.com).

Outbound traffic demand is primarily driven by our BDR (Business Development Rep) team.  The BizOps team identifies and enriches data for optimal prospects which we then provide to the BDR team to cold call. Similar to the inbound flow, BDRs will attempt to schedule demos with prospects where an AE will then run the demo with the prospect and try to convince them to use Owner (Owner.com).

Once a demo has been booked with a prospect, the lead will transition into a sales “opportunity” in our CRM. When it comes to our pricing model, Owner (Owner.com)collects revenue in 2 ways

1. Monthly subscription of $500 / month

2. A take rate of 5% for online sales conducted through our product

### **Case**

Act as if you are running the GTM analytics of Owner.com. Based on the data provided, your task is to build a scalable data product that supports recommendations and outlines actionable next steps the GTM team can take to:

1. ***Scale 2-3x** within the next year*

2. ***Improve CAC:LTV ratio** as much as possible*

Your output should contain a GTM related data product created in SQL with the snowflake data provided (you can create one or more data products). Please use best analytics engineering practices, but it doesn’t have to be a DBT project. Please make sure your solution will act as SSOT (single source of truth) and will scale. Feel free to add comments about current snowflake tables structure, and potential improvements. 

Based on your data product, what are 2 biggest opportunities you see there, in order to drive GTM function?

This exercise is intentionally ambiguous - we’re excited to see what data product you’ll implement. We’ve already built many of them, we know the biggest gaps and opportunities, but we’re wondering if you can find one of them. 

Please share your data product on a github repo, so we can review the code properly.

For opportunities, feel free to use whatever form works for you. If two results will be great, you will be invited for the presentation call with the following agenda:

- 5 minutes intros (VP of BizOps, Director of Data, Analytics Engineers)

- 30 minutes on created data product and core opportunities

- 15 minutes for GTM + Values

- 10 minutes for candidate questions

### **Common Rejection Reasons**

**1. Lack of structure & documentation**  
Missing or weak documentation around the data product built  
Assumptions not clearly stated  
👉 Make sure you follow best practices and clearly document your approach, key decisions, and assumptions.

**2. dbt project structure**  
dbt projects that are hard to follow or poorly organised  
👉 Keep the structure clean, logical, and easy to navigate — imagine someone new picking it up.

**3. Missing methodology explanations**  
No clear explanation of lead scoring or pipeline logic  
👉 Be explicit about how and why you’ve approached this the way you have.

**4. Technical fundamentals**  
Incorrect SQL joins (e.g. merging expenses with sales costs incorrectly)  
Broken or non-working code  
👉 These tend to be viewed as fundamentals, so it’s important everything runs cleanly.

**5. Lack of decision justification (very important)**  
There are multiple valid modelling approaches  
Candidates often fail by not explaining why they chose one over another  
👉 Be prepared to clearly justify your design choices, talk through trade-offs, and explain the implications and impact of your decisions.

### **Snowflake Login Instructions**

[Login link](https://app.snowflake.com/gvszsbn/tea10269/#/data/databases)

Username: de_case_vasilysouzdenkov

Pw: AF1f2I23fFIf20mjQ91a

output database: demo_db

schema: demo_db.gtm_case

wh: case_wh