# Final Report: Branch Prediction Simulation Using gem5

1. [Proposal](proposal.html)
2. [Mid-term progress report](progress.html)
3. **Final report**

CS/ECE 570. March 15, 2022.  
Adit Agarwal, Gabriel Kulp, Vaibhavi Kavathekar, Vlad Vesely.


## Summary
Branch prediction is an essential component of high-performance processor design. Different branch predictors are good in different situations, so choosing the right predictor for your workload is essential. We took on the project of researching various predictor algorithms, then working through the process of simulating them. Our goal was to provide a reference for future projects or classes and demonstrate the feasibility of microarchitectural simulations in a group coursework setting, rather than to design an original predictor or choose the best predictor for a certain workload. Therefore, we chose to simulate state-of-the-art predictors against classic simulators for the purpose of demonstrating branch prediction in gem5.

To select useful branch predictors to simulate, we examined recent processor implementations and theoretical papers from academia. We then chose the gem5 open-source full-system simulator to explore the build process and runtime options for simulating a variety of branch predictors across several benchmarks and several instruction set architectures.

## Background and Branch Predictor Selection

We divide predictors into three waves: Classic, "State of the Art", and Cutting Edge (see Fig. 1). Classic predictors were developed in the 1980s and 1990s. Most of these have been covered during the course of ECE570, and thus their analysis is left to the reader. Cutting edge predictors are new predictors, developed 2018-2022, that show high performance, but that have not yet been rigorously examined or have some flaws that prevent them from being implemented well. Our focus is on high performance predictors developed 2001-2018, which we term "state-of-the-art".

![Fig. 1: Our classifications of branch predictors. [3]](final-fig-1.png){#fig:label}

We looked at two different pieces of evidence for determining which predictors to consider state-of-the-art.

First we examined use by recent processor designs. Although Intel and Apple are very sensitive about details of their branch predictors, several other major companies have released academic papers or whitepapers detailing predictor architectures their recent flagship processors utilize. Perceptron predictors are used in AMD Zen, AMD Zen 2 cores (released 2017 and 2019), and Samsung Exynos processors (2011-2019) [zen] [sams]. The only known use of a TAGE predictor is in the AMD Zen 2 core [zen]. Based on this track record, TAGE and Perceptron predictors can be clearly categorized as both practical and high performance.

Second we examined results from Championship Branch Prediction competition. CPB is a session that is occasionally attached to International Symposium of Computer Architecture (ISCA) conferences. Despite less adoption by industry, TAGE predictors have won every Championship Branch Prediction (CPB) competition since the family was introduced. TAGE predictors currently have the highest potential for branch predictor improvement in future years, contingent on improvements in practical elements, to be addressed later.

Multiple versions of both the TAGE and the Perceptron branch predictors were included in gem5, allowing them to be simulated without the creation of custom models.

### TAGE Branch Predictor

The first TAgged GEometric history branch predictor (TAGE) was introduced in 2006 [first-TAGE]. TAGE predictors use a base predictor with multiple partially tagged branch histories that modify the base prediction. The history of each branch is of a different length in order to capture system behavior better without collisions. Structurally, TAGE is a combination of the GEHL and PPM-like predictors [O-GEHL] [PPM-like]. The PPM-like predictor was the first multi-order approximation of the Prediction by Partial Matching (PPM) text compression algorithm. This algorithm was first used in branch predictors in 1998 by the YAGS predictor [YAGS]. By combining the geometric history length of the GEHL predictor with the multiple PPM approximation of PPM-like, the TAGE family can achieve very long history lengths.

![Fig. 2: TAGE Branch Predictor [TAGE-L]](final-fig-2.png){#fig:label}

**Table Sizes:** The basic structure is shown in Fig 2. Here we note that the storage size increases with the T number. Here we could use the following geometric history algorithm:
$$L(i) = (int)(ai-1*L(1) + 0.5)$$
If $L(1) = 2$, and $a = 2$, then the following table of history lengths would result. Note that these coefficients could be changed. TAGE predictors have been evaluated with up to 30 tables [TAGE-CBP2016]. Addition of more tables benefits the prediction by allowing evaluation of longer correlations or smaller increments between history lengths, but after a certain point are not practical. This will be addressed later.

| Table # | T0 | T1 | T2 | T3 | T4 |
|---------|----|----|----|----|----|
|History Entry Count|0|2|4|8|16|

**Prediction:** The prediction contained in each table is stored as a counter. If negative, the value is "Not Taken" (NT). If positive, the prediction is "Taken" (T).

**Tags:** Tags are checked against the program counter. When a match occurs, the corresponding prediction is passed to the muxed path.

**Selection:** When one or more tables assert a tag match, the one with the longest history (highest T#) takes precedence. This is implemented very simply by the set of muxes shown in the bottom of Fig 2. This function is a "meta-predictor": a predictor that predicts which predictor will be most accurate.

**Base Predictor:** If no tag matches the program counter, the base counter's prediction is used. This is typically implemented as a bimodal predictor.

**Useful Counter:** The useful counter keeps track of how useful a particular prediction entry is, and provides the decision on how to. When a prediction is selected as the output prediction, the count is increased. Note that this is different than a tag match. Rather, it is whether this prediction was the dominant prediction that actually propagated to the output. This allows the predictor to figure out which tag entry to throw out and re-allocate to a new PC address. By being able to find the oldest tags the predictor can more safely replace branches that are not likely to be called again. This is the basic thrust of the useful counter. Multiple adaptions to the useful counter have been adopted. This is one of the more active areas of discussion in TAGE predictors.

#### Advanced TAGE Features and Improvements
The most widely adopted improvements to this architecture are the Statistical Corrector (SC) secondary predictor, and the Loop Predictor (LP), as shown in Fig. 3. These fortify the original TAGE predictions for specific circumstances that prove troublesome. Later TAGE predictors also improve the useful counter update policy.

![Fig. 3: Structure of a TAGE-SC-L Branch Predictor [TAGESCL]](final-fig-3.png){#fig:label}

Loop predictors attempt to identify fixed-length loops. Essentially this checks to see if a loop has exited after the same number of iterations multiple times. If a loop executes N times for several calls, then when the loop comes up in the future, it is signaled as a loop with length N. The Nth iteration is then predicted to be a loop exit, and the loop predictor overrides the TAGE predictor [TAGE-L]. This can be very helpful for situations such as inner loops.

Weakly correlated branches and the necessity of statistical correlators were not explained well by Seznec in his TAGE papers. Michelund examines the root issue [TAGE-like]. Essentially the TAGE family has a difficult time predicting branches that do not bias strongly in one direction. If a branch only goes in one direction 40% of the time (0.4), then it takes more iternations for the predictor to properly predict it than a branch that has the same result 90% of the time. A statistical corrector detects these branches that are not well correlated with their local history, and proceeds to invert the TAGE output when it fails to predict these branches correctly [TAGE-LocalSC]. The SC is placed after the TAGE as shown in Fig. 2. These features were coupled with the base TAGE predictor in 2014 to form the TAGE-SC-L [TAGESCL].

As mentioned in the predictor survey, the TAGE predictor has won every CPB. Why then do many companies ignore TAGE in favor of Perceptron? While CPB results are useful, the submissions are only limited by the memory size allocated for predictors. Latency is not included. In fact, most TAGE papers do not discuss latency at all. However, we conjecture that there is an approximately linear increase in delay with the addition of each table, due to the addition of additional multiplexers in the critical path flowing from the base predictor to output. Such a trend is unfortunate since accuracy in general increases with the number of tables. For example, to achieve maximum performance at CBP 2016, the proposed TAGE-SC-L used 30 history tables.

The lack of attention to latency may be a reason that TAGE predictors are not used very often at high performance levels. One solution is to use it in parallel with a lower latency predictor. AMD places their TAGE-SC-L in conjunction with a lower latency Perceptron predictor [zen]. This is one region where active research may yield results for industry.

### Concept of Perceptron

![Fig. 4: Structure of a General First-Order Perceptron Neural Network](final-fig-4.png){#fig:label}

The perceptron is an early form of neural network invented in 1962 [Perceptron BP]. Perceptrons can classify inputs based on a linear function. They fit in the supervised learning category of machine learning. It accepts some inputs $x$ and contains $w$ weights and bias.

The bias is an added adjustable term to the sum of inputs and weights that allows the shift of the activation function for increased model accuracy. The result is calculated by multiplying the inputs with their corresponding weights, summing these products, and then passing through an activation function.

This operation can be understood by a simple equation:
$$y = w_0 + \sum_i{n(x_i\cdot w_i}$$
Where $n$ is the activation function and $i$ indexes the weights and activations.

### Perceptron Branch Predictor

![Fig. 5: Structure of a perceptron branch predictor [perceptron-diagram]](final-fig-5.png){#fig:label}

The decision-making of the perceptron branch predictor, shown in Fig. 5, is easy to understand. The predictor assigns each bit of the history register a corresponding weight and if a bit is correlated more than the other bits, the magnitude of that particular weight is higher. Thus, the perceptron learns correlations between bits in the branch history register.  These weights are summed together as shown above. The outcome is a number, i.e. 1 or -1, that corresponds to T or NT.  

The main advantage of using a perceptron neural network in branch prediction is its use of long history lengths as it only requires space linear in history length, as opposed to other predictors such as Gshare which require space exponential in the history length.  The 2001 perceptron was the first branch predictor to be capable of using global branch history tables with more than 60 entries [TAGE-like].

#### Perceptron Branch Predictor Operation
- Initially the branch address is hashed in order to produce an index.
- This index is used to fetch a particular perceptron into a vector register of weights $w$.
- One of the integral components of the perceptron Branch Predictor is its Branch History register which maintains a record of all the oldest and the most recent branches.
- After the perceptron is fetched into the vector register, the dot product is performed between the Branch History register and the weights.
- As stated above, the computation of perceptron output is easy and is determined on the value of $y$ which is an integer. If the value of $y$ is 1, the branch is predicted to be taken and if the value of $y$ is -1, the branch is predicted to be not taken. 
- Finally, after the actual outcome of the branch is known, the training algorithm uses the actual outcome and the value of $y$ in order to update the weights in the perceptron table.
- Perceptron neural network relies just on pattern history (branch taken or not taken) which makes it suitable for just linearly separable branches.

### Advancements in Perceptron Branch Predictors
There has been evolution in Perceptron Branch Predictors over the years.  One of the common factors of improvement in most of the proposed perceptron/neural network predictors is the weight selection approach. 

**Fast Path Based Neural Predictor:** The operation of the predictor can be easily interpreted by the graph in Fig. 6, where the predictor predicts a branch by selecting a neuron along the path to that particular branch in order to make a prediction, rather than selecting all the neurons simultaneously based on the available branch address. This approach increases the accuracy and decreased the latency of the predictor.  Prior to this approach, the original perceptron had a latency of 4 cycles, which rendered it impractical.  This reduces the latency to around 1 cycle. The predictor uses the path and the pattern history together which is useful to predict linearly and non-linearly separable branches. [Fast Path BP]

![Fig. 6: Principal Innovation of the Fast Path Perceptron [Fast Path BP]](final-fig-6.png){#fig:label}

**Global/Local Hashed Perceptron:** The predictor combines the local and the global history as shown in Fig. 7 to index the weights of the perceptron as opposed to the previous versions of the perceptron branch predictors which use just the local history or global history for the weight selection process. Some weights are selected by XORing the local branch history with the branch address and some are selected by XORing the global branch history with the branch history, thereby lowering the misprediction rate and increasing the accuracy over the fast path based neural predictor [Global/local BP].

![Fig. 7: Novel Addressing of Global/Local Hashed Perceptron [Global/local BP]](final-fig-7.png){#fig:label}

### Cutting-Edge Predictors

Most of the neural branch prediction schemes using advanced machine learning algorithms and multilayer neural networks are based on the original perceptron model.  The original perceptron branch predictor is only able to classify linearly separable branches, so these more advanced networks add more layers and different structures to recognize more complicated functions.  

Some of the most recent advanced neural predictors include:

**Sliced Recurrent Neural Networks (2020):**

![Fig. 8: Sliced Recurrent Neural Network [SRNN]](final-fig-8.png){#fig:label}

This particular branch predictor uses the concept of the Sliced Recurrent Neural Network algorithm in order to make the branch predictions. The principal of SRNN is based on the operation of RNN(Recurrent Neural Network). The distinguishing factor of the RNN’s from the other neural networks is memory [SRNN]. 

The RNN network structure, shown in Fig. 8, operates in a way that the subsequent nodes remember the information and this information is then passed to the corresponding nodes and eventually to the output. 

The SRNN uses the input subsequence of RNN, divides the sequence, runs RNN on each subsequence and merges the output of each subsequence as a new input sequence in order to compute the output.

**DNN Based Models:**
Deep Neural Networks are a set of algorithms in order to train multilayer neural networks. These algorithms, when used in Branch predictors, have the same input and output structure as that of the perceptron branch predictor, although the middle part comprises the RBM’s (Restricted Boltzmann’s machine) and several hidden layers for its operation.  This predictor's performance was nearly the same as that of the 2016 CBP winner, showing that this advanced approach has promise regarding cutting-edge performance [CNN].

![Fig. 9: Deep neural network [CNN]](final-fig-9.png){#fig:label}

These more advanced neural network branch predictors require offline training (training on datasets before operation).  This limits their applicability to general processing applications, where program flows are diverse.  Current predictors are all able to operate without prior training, and thus have a great advantage.  It remains to be seen if effective initialization policies will be invented to deal with the training requirement.  Since clever initialization schemes have already been used to improve TAGE predictors across time (indeed, one of the main improvements of the TAGE over the PPM-like predictor was its useful counter initialization policy [first-TAGE]), it may be possible for designers to make these more complicated neural networks viable for use in real systems.
