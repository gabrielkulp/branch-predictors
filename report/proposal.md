# Proposal: Branch Prediction Simulation Using gem5

1. **Proposal**
2. [Mid-term progress report](progress.html)
3. [Final report](final.html)

CS/ECE 570. January 20, 2022.  
Adit Agarwal, Gabriel Kulp, Vaibhavi Kavathekar, Vlad Vesely.


## Motivation
Branch prediction is nothing new, but it's also not a fully-explored field. There are recent papers on novel techniques [1,2,3,4,5], and the chip design industry embracing accelerators [6] which could plausibly require control flows with different branch behavior than standard benchmarked workloads.

This leads naturally to an educational requirement, not just for existing tried-and-true techniques like 1-bit, correlating, and tournament predictors, but also for a general methodology to evaluate new and existing algorithms in arbitrary workloads. Further, it would be ideal to realize such a methodology with industry-standard open-source tooling that will translate directly to both industry and academic projects.


## Background
In computer architecture, when execution reaches a conditional jump, a branch prediction circuit guesses whether the jump will be taken or not before the calculation of that condition has finished [7]. This is an important piece of a pipelined processor, since a correct prediction allows the pipeline to continue at full speed while an incorrect prediction leads to performance loss when in-progress execution must be discarded. The absence of a predictor is the same as mispredictions, since the fetch stage must stall to find out what it needs to fetch, wasting the same number of cycles as would be discarded with a misprediction.

There are many algorithms that observe aspects of execution to make their predictions, with accuracy easily passing 90% [7]. (We'll describe some methods here.)

One way to find accuracy metrics is by simulating a benchmark application and tracking statistics. gem5 is one such simulator, used in academia and industry [8]. gem5 is like a virtual machine in that it is capable of running programs and booting unmodified Linux, but it also reports detailed performance and power consumption data, and allows you to specify custom and novel microarchitectures [8].

Putting these together, we can simulate the performance of various branch prediction strategies across a range of benchmarks, and learn a popular and powerful tool at the same time.


## Objectives
We propose to simulate various branch prediction algorithms and compare their performance in standard benchmarks on RISC-V, ARM, and X86 instruction set architectures. This will include at least 1-bit and correlating predictors (alone and in a tournament), along with some other algorithms we choose from recent publications (choosing, understanding, and implementing these is part of the project).

We also want to document our use of gem5 in sufficient detail that a student could replicate our work with minimal consultation of other resources. Ideally, our project will stand as a template for further simulation work in gem5, and could be used as a starting point for curriculum development or on-the-job training.

We hope to plot accuracy versus predictor size for each method, either best-case, average, or per benchmark.


## Development Timeline
| Week | Goal                                                |
|:----:|-----------------------------------------------------|
|  3   | Jan. 20: Proposal due                               |
|  4   | 4 Predictors chosen, existing predictors simulated  |
|  5   | Explore gem5 and custom microarchitecture configs   |
|  6   | First custom predictor simulated                    |
|  7   | Feb. 17: Mid-report proposal due                    |
|  8   | All custom predictors simulated                     |
|  9   | Mar. 3-10: Final presentation                       |


## Work Allocation
- **Adit:** predictor implementation
- **Gabriel:** sim configuration and source management (gem5 wrangler)
- **Vaibhavi:** predictor research and documentation
- **Vlad:** documentation lead (and a little predictor research)


## References
1. Nain, Sweety, and Prachi Chaudhary. “Implementation and Comparison of Bi-Modal Dynamic Branch Prediction with Static Branch Prediction Schemes.” International Journal of Information Technology, vol. 13, no. 3, Springer Singapore, 2021, pp. 1145–53, https://doi.org/10.1007/s41870-021-00631-z.
2. Mittal, Sparsh. “A Survey of Techniques for Dynamic Branch Prediction.” Concurrency and Computation, vol. 31, no. 1, WILEY, 2019, p. e4666–n/a, https://doi.org/10.1002/cpe.4666.
3. Seznec, Andre, et al. “Practical Multidimensional Branch Prediction.” IEEE MICRO, vol. 36, no. 3, IEEE, 2016, pp. 10–19, https://doi.org/10.1109/MM.2016.33.
4. Mao, Yonghua, et al. “Exploring Convolution Neural Network for Branch Prediction.” IEEE Access, vol. 8, IEEE, 2020, pp. 152008–16, https://doi.org/10.1109/ACCESS.2020.3017196.
5. Mohammadi, Milad, et al. “Energy Efficient On-Demand Dynamic Branch Prediction Models.” IEEE Transactions on Computers, vol. 69, no. 3, IEEE, 2020, pp. 453–65, https://doi.org/10.1109/TC.2019.2956710.
6. RISC-V International. "RISC-V Summit." Dec 6-8, 2021. https://events.linuxfoundation.org/riscv-summit/.
7. Parihar, Raj. "Branch Prediction Techniques and Optimizations" (PDF). Archived from the original (PDF) on 2017-05-16. Retrieved 2017-04-02. https://web.archive.org/web/20170516211522/http://www.cse.iitd.ernet.in/~srsarangi/col_718_2017/papers/branchpred/branch-pred-many.pdf.
8. About gem5. https://www.gem5.org/about (accessed Jan 11, 2022)
