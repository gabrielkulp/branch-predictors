# Progress Report: Branch Prediction Simulation Using gem5

1. [Proposal](proposal.html)
2. **Mid-term progress report**
3. [Final report](final.html)

CS/ECE 570. February 17, 2022.  
Adit Agarwal, Gabriel Kulp, Vaibhavi Kavathekar, Vlad Vesely.

## Objectives
This project has three aims. First, to provide an introduction to the major advancements in branch prediction since 2000. Second, to instruct in the usage of gem5 for simulation of branch predictors. Third, to present comparative simulation results for modern and classic branch predictors.

Why should a student of computer architecture care about branch predictor research? Although the field of branch prediction is a small one, there are many options to choose from based on characteristics such as maximum prediction accuracy, latency, and space-limited performance. These options should be considered when weighing design tradeoffs in new superscalar processors, basic microcontrollers, and novel accelerators.

gem5 is an integral part of processor feature design. As an open source, highly customizable simulator, it is a valuable tool for any designer looking to create architecture improvements or compare current configurations. Setting up gem5 and branch simulation can be difficult, so this report provides a valuable introduction to the subject.

## Status Update
So far we have conducted research into the most effective branch predictors proposed over the past 20 years. Initial simulations have allowed us to measure basic branch misprediction rates on a small program. Several important high performance branch predictors were selected for description and simulation. Over the next few weeks we will simulate these predictors with useful benchmarks to determine performance in various situations.

Here is our project timeline, updated to reflect the main focus of the past weeks, and our new goals for future weeks.

|Week| Goal                                                       |
|----|------------------------------------------------------------|
| 3  | Jan. 20: Proposal due                                      |
| 4  | Research existing branch predictors and how they work      |
| 5  | Explore gem5 and its build process                         |
| 6  | Begin gathering branch prediction statistics               |
| 7  | Feb. 17: Mid-report proposal due                           |
| 8  | Finish simulation of all predictors and benchmarks         |
| 9  | Formalize our findings in branch prediction and gem5 usage |
| 10 | Mar. 8: Final presentation                                 |


What follows is a summary of our current progress and understanding for each of our topics. This information, once properly expanded, verified, and understood, will form the basis of our presentation on March 8th.

## Literature Review

### Branch Predictors
Branch predictor research reached its high point in the 1990's with the invention of Gshare, and began to fall off by the early 2000's. As the field narrowed, the remaining researchers were able to create the fundamental predictors that are used in current-day superscalar processors. These consist of the TAGE and Perceptron predictor families.

The family of TAged GEometric hybrid (TAGE) predictors have consistently captured top spots at the Championship Branch Prediction (CBP), a contest held every ~5 years to determine the best branch predictors. The championship is split into multiple categories with different space limitations. Not only are they highly effective with unlimited memory, but at practical levels as well. Some standard sizes for CBP buffer limits are 64Kb and 256Kb. TAGE predictors are used in modern processors such as the AMD Zen 2, where it is used as the main predictor [1].


### TAGE Predictors

![Fig. 1 TAGE Branch Predictor [4]](progress-fig-1.png){#fig:label}

The first TAGE predictor was introduced in 2006 [2]. TAGE predictors use a base predictor with multiple partially tagged branch histories that modify the base prediction. The history of each branch is of a different length in order to capture system behavior better without collisions. The key innovation of the TAGE predictor was the use of history lengths that scaled as a geometric series.

### Advanced TAGE Features and Improvements
The most widely adopted improvements to this architecture are the Statistical Corrector (SC) secondary predictor, and the Loop Predictor (LP). These fortify the original TAGE predictions for specific circumstances that prove troublesome.

![Fig. 2. Structure of a TAGE-SC-L Branch Predictor [3]](progress-fig-2.png){#fig:label}

Loop predictors attempt to identify fixed-length loops. Essentially this checks to see if a loop has executed for the same number of instructions multiple times, then when the loop comes up in the future, it is signaled as a loop with length N. The Nth iteration is then predicted to be a loop exit, and the loop predictor overrides the TAGE predictor [4].

A statistical corrector detects branches that are not well correlated with their local history, and proceeds to invert the output of the main TAGE predictor when it fails to predict these branches correctly [5]. To invert the output, the SC is placed after the TAGE as shown in Fig. 2. These features were coupled with the base TAGE predictor in 2014 to form the TAGE-SC-L [3].

### Background and Previous Work on Perceptron Predictors:
Perceptrons were first introduced to the field of branch prediction by Jimnez and Lin [6] in 2001, where they discovered that the perceptron predictor was more effective and accurate than the gshare and bi-mod predictors. They also evaluated a hybrid predictor which combines the gshare and the perceptron predictor respectively.

There are several important factors in Jimnez and Lin's work: improvement in analyzing branch behavior, decrease in the branch misprediction rate, and less complex way of computing the perceptron output. Another important factor of their work in hardware implementation of the perceptron predictor was that they hypothesized that the main advantage of perceptron over Gshare was the use of longer history lengths, since Gshare requires space linear in the history lengths.

To further improve the long latency produced by the simple perceptron branch predictor, Jimnez and Lin introduced fast path based neural branch prediction [7]. In 2007, Anthony S. Fong and C. Y. Ho introduced Global/Local Hashed Perceptron Branch Prediction [8] which was based on the hashing of the local and global histories, as opposed to all the previous perceptron predictors which used just the local or global histories and which outperformed the fast path based neural predictor by achieving an improvement in the misprediction rate by 26.9% [Global/LocalPBP].

### What is a Perceptron?
The perceptron is an early form of neural network invented in 1962. Perceptrons can classify inputs based on a linear function. They fit in the supervised learning category of machine learning. It accepts some inputs ‘x’ and contains ‘w’ weights and bias.

The bias is an added adjustable term to the sum of inputs and weights that allows the shift of the activation function for increased model accuracy. The result is calculated by multiplying the inputs with their corresponding weights, summing these products, and then passing through an activation function.

![Fig. 3. Flow of a Single Layer Perceptron Neural Network [9]](progress-fig-3.png){#fig:label}

### Perceptron Based Branch Prediction Process
1. Perceptron branch predictor uses a perceptron in place of a row of n-bit predictors.
2. Branch history (the last `n` branches, either from local or global history) is used as the input to the perceptron function.
3. Whenever a conditional branch is encountered, the History Register keeps a record of the outcomes of all including the most recent and the oldest branches.
4. The value of `y` is calculated by the summation of inputs with the corresponding weights. If `y=1`, the branch is taken and if `y=-1`, the branch is predicted to not be taken.
5. The prediction helps us determine instructions to be executed, after execution of the instruction, if the actual outcome of the branch states that if the prediction was wrong or if the sum used to make the prediction is lesser than the magnitude θ, The corresponding weights are updated by using the product of the actual outcome and the value of `y`.
6. The result is then written back to the perceptron table.
The perceptron branch prediction can be understood by using a simple formula as below.
 $$y = w_0 + \sum_{i=0} n (x_i \cdot w_i)$$
Where $w$ are the weights and $x$ are the perfeptron inputs.

![Fig. 4. Perceptron Branch Predictor [6]](progress-fig-4.png){#fig:label}

Advanced Perceptron Branch Predictor:
Bit level perceptron Prediction for Indirect Branches

![Fig. 5. Branch Level Bit Predictor [10]](progress-fig-5.png){#fig:label}

Direct Branches contain the instruction destination address in the body of the instruction as opposed to Indirect Branch includes a pointer to the memory address which contains the instruction destination address.
For an example of an Indirect branch instruction, consider a `sub` instruction with the Program Counter as one of the Destination Registers.

### SUB PC,PC,#4
The proposed predictor uses indirect branching instead of direct branching, along with perceptrons to predict the bits in order to improve the misprediction rate.

The [10] uses the concept of Scaled Neural Indirect Prediction (SNIP) Predictor [11] which is based on predicting several bits of the target address and then choosing a known target with the most matching bits.

It is composed of an Indirect Branch Target Buffer (IBTB) to store up to 64 indirect branch targets and each IBTB entry is tagged with 9 bits. The addresses of the possible target bits and the predicted target bits are compared to determine the predicted target. The actual target is then stored in the IBTB.

The BLBP consists of sub predictors which are used for predicting values for each target , after predicting the values it adds the output for the equivalent sub predictor for that particular bit and builds a vector and compares the similarity of target with the vector.

## Predictor Simulation in gem5

### Building gem5

In theory, the gem5 build process is simple: install dependencies, clone the repo, and then type `scons build/RISCV/gem5.opt`. However, installing the correct dependencies is difficult to coordinate between group members, and the fastest of our laptops still takes over 20 minutes to finish the build.

We chose to build gem5 in a container to overcome these issues. We chose Docker for containerization since documentation and guides are easy to come by and it's a popular choice for isolating and standardizing build processes. Using docker requires a special script ([here](https://github.com/gabrielkulp/branch-predictors/blob/main/Dockerfile) is our Dockerfile) that defines the automated procedure to create a container. This script contains all the build step mentined in the gem5 build instructions, but in a standard way that will work for Linux, MacOS, and Windows hosts. Second, we have a wrapper script that constructs the right Docker command to spin up this container, give it access to the configuration file and benchmark binary we want to run, and makes the simulation output files available to the host (again, agnostic of host OS).

Finally, this gem5 container image can be distributed among group members for performing tests, since the same image can be used to create identical containers on any platform that supports Docker. This means that all group members have access to the gem5 binary, including any of our modifications, with only minimal individual setup: whether building or running, we need only to have `docker` and `git` installed (and `git` can even be avoided by downloading an archive of our code repository).

### Branch Predictor Simulations
We began our simulations by testing the default "Hello World" program with a local predictor in several architectures. This is not necessarily a fair or effective benchmark. Rather, it operates as a proof of concept run that showed the ability to simulate branch prediction and acquire relevant statistics. We will run more representative benchmarks to draw useful comparisons later, but for now we are just getting to know our tools, and "Hello World" removes a lot of potential complexity.

Most of the modern predictors are already implemented as microarchitecture options in gem5. We chose to test with 1b, 2b, TAGE, TAGE-SC-L and Perceptron predictors. The benchmark for predictors is traditionally mispredictions per kilo-intruction (MPKI). This is meant to allow total benchmark performance differences when comparing predictors. With this number and the branch penalty, total performance difference between predictors can be detected.

Here is some preliminary data from RISC-V, just to demonstrate that we have managed to run some simulations already. These benchmarks is not representative of real-world performance, and we plan to test x86 and ARM for our final report, but for now we have demonstrated the ability to gather data:

|Predictor       |Local|Bimodal|Tournament|TAGE |TAGE-L|
|----------------|-----|-------|----------|-----|------|
|Num Instructions|5518 |5518   |5518      |5518 |5518  |
|Mispredicts     |408  |520    |462       |405  |409   |
|MPKI            |73.93|94.24  |83.72     |73.39|74.12 |

|Predictor       |Multiperspective Perceptron 8KB|TAGE-SC-L 8KB|Multiperspective Perceptron 64KB|TAGE-SC-L 64KB|
|----------------|-------------------------------|-------------|--------------------------------|--------------|
|Num Instructions|5518                           |5518         |5518                            |5518          |
|Mispredicts     |137                            |399          |136                             |396           |
|MPKI            |24.82                          |72.3         |24.64                           |71.76         |

These tests were run with variations on this command:

```
gem5 configs/example/se.py --cpu-type=O3CPU --caches --l2cache \
     --bp-type=LocalBP -c tests/test-progs/hello/bin/riscv/linux/hello
```

## References

[1] D. Suggs, M. Subramony and D. Bouvier, "The AMD “Zen 2” Processor," in IEEE Micro, vol. 40, no. 2, pp. 45-52, 1 March-April 2020, doi: 10.1109/MM.2020.2974217.  
[2] A. Seznec and P. Michaud "A Case for (Partially) TAgged GEometric History Length Branch Prediction" Journal of Instruction Level Parallelism, vol. 10, Feb 2006. https://jilp.org/vol8/v8paper1.pdf [Accessed Feb 15, 2022]  
[3] A. Seznec, "TAGE-SC-L Branch Predictors" presented at JILP - Championship Branch Prediction, Minneapolis, United States, June 2014, https://hal.inria.fr/hal-01086920  
[4] A. Seznec, "The L-TAGE branch predictor," in Journal of Instruction Level Parallelism, vol. 9, May 2007. https://jilp.org/vol9/v9paper6.pdf [Accessed Feb 8, 2022]  
[5] A. Seznec, "A New Case for the TAGE Branch Predictor," MICRO 2011 : The 44th Annual IEEE/ACM International Symposium on Microarchitecture, 2011, ACM-IEEE, Dec 2011, Porto Allegre, Brazil. hal-00639193  
[6] D. A. Jimenez and C. Lin, "Dynamic branch prediction with perceptrons," Proceedings HPCA Seventh International Symposium on High-Performance Computer Architecture, 2001, pp. 197-206, doi: 10.1109/HPCA.2001.903263. [Accessed 3rd Feb]  
[7] D. A. Jimenez, "Fast path-based neural branch prediction," Proceedings. 36th Annual IEEE/ACM International Symposium on Microarchitecture, 2003. MICRO-36., 2003, pp. 243-252, doi: 10.1109/MICRO.2003.1253199.  
[8] A. S. Fong and C. Y. Ho, "Global/Local Hashed Perceptron Branch Prediction," Fifth International Conference on Information Technology: New Generations (itng 2008), 2008, pp. 247-252, doi: 10.1109/ITNG.2008.258.  
[9] A. D. Halke and A. A. Kulkarni, "CPU Branch Prediction Using Perceptron," 2021 IEEE 8th Uttar Pradesh Section International Conference on Electrical, Electronics and Computer Engineering (UPCON), 2021, pp. 1-5, doi: 10.1109/UPCON52273.2021.9667663.  
[10] E. Garza, S. Mirbagher-Ajorpaz, T. A. Khan and D. A. Jiménez, "Bit-level Perceptron Prediction for Indirect Branches," 2019 ACM/IEEE 46th Annual International Symposium on Computer Architecture (ISCA), 2019, pp. 27-38.  
[11] D.A. Jimenez, "SNIP: Scaled Neural Indirect Predictor" presented at the 2nd JILP Workshop on Computer Architecture Competitions (JWAC-2), San Jose, USA, June 2011 https://jilp.org/jwac-2/program/cbp3_09_jimenez.pdf [Accessed Feb 16, 2022]  


