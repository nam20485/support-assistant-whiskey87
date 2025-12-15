

# **Architecting AI for Open-Source Windows Applications: A Cost-Benefit Analysis of Local vs. Cloud Inference for Technical Support**

## **Section 1: The Strategic Dilemma: Local vs. Cloud AI for Sustainable Open-Source Projects**

### **1.1 Framing the Core Decision for FOSS**

The integration of Artificial Intelligence (AI) into desktop applications represents a paradigm shift in user experience and functionality. For a free, open-source software (FOSS) project, particularly one aimed at providing technical support, this integration presents a fundamental strategic challenge. The core of this challenge lies not in the technical feasibility of AI, but in the long-term financial sustainability of the chosen architecture. For any FOSS project operating without a direct monetization strategy, the introduction of developer-side recurring operational expenditure (OpEx) is not merely a line item on a budget; it is an existential threat. Every API call that incurs a cost, no matter how small, creates a direct and perilous link between the application's success and the developer's financial burden. As the user base grows, so does the cost, creating a model that punishes popularity and is inherently unsustainable for a volunteer or community-driven project.

This report provides an exhaustive analysis of the two primary architectural paradigms for deploying AI inference capabilities—on-device (local) and cloud-based—within a Windows desktop application. The evaluation is consistently framed through the critical lens of minimizing or eliminating developer-side recurring costs, ensuring the long-term viability and success of a free, open-source distribution model. The central thesis is that while cloud services offer immense power, their cost structure is fundamentally incompatible with the FOSS ethos. Conversely, the modern Windows AI platform now provides a mature, powerful, and cost-effective framework for deploying high-performance AI locally, aligning perfectly with the project's financial and philosophical constraints.

### **1.2 Introducing the Two Paradigms**

The choice between on-device and cloud-based AI is a decision between two fundamentally different service delivery and cost models. Understanding their distinct characteristics is essential for making an informed architectural commitment.

#### **On-Device (Local) Inference**

This paradigm involves packaging and running the AI model directly on the end-user's computer hardware. From the developer's perspective, the primary cost is the one-time capital expenditure (CapEx) of development effort—the time and resources invested in selecting, optimizing, and integrating the model into the application. The recurring operational costs, such as the electricity required to power the user's CPU, GPU, or NPU, are externalized to the user. This is a standard and universally accepted model for desktop software, where applications have specified "system requirements" to function correctly.1 The developer is responsible for creating the software, and the user is responsible for providing the hardware to run it. This model decouples the application's popularity from the developer's operational costs, making it structurally sound for FOSS distribution.

#### **Cloud-Based Inference**

This model operates on a utility computing basis. The AI model is hosted on powerful servers managed by a third-party provider (e.g., Microsoft Azure, OpenAI, Amazon Web Services). The desktop application sends user queries over the internet to the provider's API and receives the model's response. This approach introduces a direct, recurring, and usage-based OpEx for the developer.3 Every query from every user translates into a billable event, typically priced per thousand tokens of input and output.4 This creates a direct, linear or even non-linear 3, correlation between user engagement and the developer's expenses. While it offers access to immensely powerful models and abstracts away hardware concerns, it fundamentally shifts the operational burden from the user to the developer, a critical and potentially fatal flaw for a non-monetized project.

### **1.3 Key Vectors of Comparison**

To provide a comprehensive and conclusive recommendation, this report will evaluate the local and cloud paradigms across five key vectors. These factors encompass the complete lifecycle of the AI feature, from financial viability to user experience and long-term maintenance.

1. **Total Cost of Ownership (TCO) & Financial Viability:** This is the paramount consideration. The analysis will go beyond surface-level API pricing to include hidden costs like data transfer and storage 3, projecting the long-term financial impact on a FOSS developer. The primary goal is the elimination of recurring costs.  
2. **Performance & Latency:** This vector examines the real-world impact on application responsiveness. Local inference offers near-instantaneous results, while cloud inference is subject to network latency, which can significantly degrade the user experience and make the application feel sluggish.6  
3. **Privacy & Security:** A critical factor for any application handling user data. On-device processing keeps all user queries and contextual data securely on the local machine, offering maximum privacy.6 Cloud-based models require transmitting this data to a third party, introducing significant privacy, security, and data sovereignty concerns.7  
4. **Scalability & Accessibility:** This assesses how each model accommodates a growing user base. Cloud models offer effortless scalability from the provider's side. Local models scale through their ability to run on a vast range of existing user hardware, from low-end CPUs to high-end GPUs and NPUs, but performance will vary based on that hardware.2  
5. **Developer Experience & Maintenance:** This evaluates the complexity, effort, and long-term burden of implementing and maintaining each solution. This includes the ease of integration, dependency management, and the strategic risks associated with vendor lock-in and price volatility.9

By rigorously analyzing both paradigms against these criteria, this report will build an evidence-based case for the optimal architectural path, ensuring the technical support application is not only powerful and effective but also sustainable for the long term.

## **Section 2: The On-Device Paradigm: Leveraging the Modern Windows AI Platform**

The viability of local AI inference hinges on the capabilities of the underlying platform. In recent years, Microsoft has made a significant and coordinated strategic investment in building a comprehensive, unified on-device AI stack for Windows. This is not merely a collection of disparate features but a deliberate, multi-layered effort to solve the historical challenges of hardware fragmentation and high development overhead, effectively making local AI a first-class citizen on the Windows platform.8 For a FOSS project, aligning with this platform strategy provides a powerful tailwind, offering a clear path to broad compatibility, high performance, and simplified development.

### **2.1 The Windows AI Stack Decoded: A Strategic Overview**

Understanding the architecture of the Windows AI platform is crucial for appreciating its benefits. It is a layered stack where each component serves a specific purpose, working in concert to provide a seamless experience for both the developer and the end-user.

#### **Windows ML**

At the highest level of abstraction sits Windows Machine Learning (Windows ML). This is a WinRT API designed to radically simplify the process of integrating AI models into C\#, C++, and Python applications.8 Its primary strategic function is to act as an abstraction layer that solves three critical problems for developers:

1. **Hardware Diversity:** Windows ML abstracts away the complexities of the underlying hardware (CPU, GPU, NPU), allowing developers to write a single code path that runs efficiently across the entire spectrum of Windows devices.8 This eliminates the need for developers to write and maintain separate, vendor-specific code for Intel, AMD, NVIDIA, and Qualcomm hardware, a task that would be prohibitively complex and expensive for a FOSS project.  
2. **Dependency Management:** Without Windows ML, an application would need to bundle the AI model, the inference runtime (like ONNX Runtime), and vendor-specific drivers and tools. This increases the application's size and places the burden of updating and maintaining these dependencies squarely on the developer.8 Windows ML shifts this burden to the operating system itself. The runtime and execution providers are managed by Windows, dramatically reducing the application's footprint and maintenance overhead. For example, Topaz Labs reported their installer size shrinking from gigabytes to megabytes by adopting Windows ML.12  
3. **Intelligent Load Balancing:** Windows ML automatically selects the most appropriate processor for the AI workload based on the hardware available on the user's device. It can choose an NPU for low-power sustained inference, a GPU for high-throughput tasks, or a CPU for maximum compatibility.12 This intelligent, automatic decision-making ensures optimal performance and efficiency without requiring complex logic within the application code.8

Windows ML will be generally available later in 2024 and is supported on Windows 11 version 24H2 (build 26100\) or greater.8

#### **ONNX Runtime (ORT)**

Powering Windows ML is the ONNX Runtime (ORT), a production-grade, high-performance, cross-platform inference engine developed by Microsoft.12 ONNX (Open Neural Network Exchange) is an open standard for representing machine learning models, allowing developers to train a model in one framework (like PyTorch or TensorFlow) and deploy it for inference in another.14 The fact that ORT is the engine behind core Microsoft products like Windows, Office, and Azure Cognitive Services is a testament to its robustness, performance, and long-term strategic importance to Microsoft.14 Its extensive language support, particularly for C\#, makes it a perfect fit for a Windows desktop application. ORT is designed to apply numerous graph optimizations to a model and then partition it into subgraphs that can be accelerated by available hardware-specific libraries, known as Execution Providers (EPs).15

#### **DirectML**

At the lowest level of the stack is DirectML (Direct Machine Learning), the API that provides the actual hardware acceleration.16 DirectML is a low-level, high-performance, DirectX 12-based library. Its most significant strategic advantage is that it provides a single, unified API for GPU and NPU acceleration across all major hardware vendors, including AMD, Intel, NVIDIA, and Qualcomm.16 For a FOSS project targeting the broad and diverse Windows ecosystem, this is a game-changing feature. It means that a single build of the application can leverage GPU acceleration on any PC with a DirectX 12-compatible graphics card, without the developer needing to write, test, and maintain separate code paths for NVIDIA's CUDA, AMD's ROCm, and Intel's oneAPI. DirectML is the key that unlocks hardware-accelerated performance at scale across the entire Windows market.19

### **2.2 Harnessing Heterogeneous Hardware: From CPU to NPU**

The primary value proposition of the Windows AI stack is its ability to harness the full range of processing units available in modern PCs, ensuring that the application is both universally functional and performant where possible.

* **CPU (Central Processing Unit):** The CPU serves as the universal baseline for execution. The Windows AI stack ensures that AI features will function on all modern x64 and ARM64 PCs, even those without a dedicated GPU or NPU.8 This guarantees the broadest possible reach for the application, encompassing hundreds of millions of Windows devices currently in the market. While CPU performance may be suitable for lighter workloads, it provides a critical fallback mechanism that ensures the application's core AI functionality is never completely unavailable to any user.  
* **GPU (Graphics Processing Unit) via DirectML:** For the majority of current gaming and professional PCs, the GPU is the workhorse for performant AI. By using DirectML as its GPU execution provider, ONNX Runtime enables a single, unified code path to accelerate inference on any DirectX 12-capable GPU.17 This is a crucial advantage. A developer can write code once and have confidence that it will be hardware-accelerated on an NVIDIA GeForce card, an AMD Radeon card, or an Intel Arc card, without any vendor-specific logic. For NVIDIA GPUs specifically, Windows ML provides full TensorRT acceleration, ensuring maximum performance on that popular platform.12  
* **NPU (Neural Processing Unit):** The NPU is the future of efficient, on-device AI, and the Windows AI stack is explicitly architected to leverage it. NPUs are specialized processors designed to accelerate neural network tasks with extremely high power efficiency.2 This is particularly important for the new generation of Copilot+ PCs, which feature NPUs from Qualcomm, Intel, and AMD.12 For a technical support application that might run in the background, the NPU is the ideal processor. It can handle "sustained inference" workloads with minimal impact on battery life, a critical consideration for mobile workstations and laptops.6

While Windows ML's automatic selection of the best execution provider is a major benefit for simplification, the framework does not remove developer control. The ONNX Runtime APIs allow for the explicit selection of an execution provider, giving developers the ability to enforce which processor is used for greater predictability and for fine-grained performance tuning if required.8

### **2.3 The Developer's Workflow for On-Device AI**

Microsoft has invested heavily in tooling to make the process of preparing an AI model for local deployment as straightforward as possible. The workflow consists of three primary stages:

1. **Step 1: Model Conversion:** The first step is to get the AI model into the standardized ONNX format. Most modern training frameworks, like PyTorch and TensorFlow, support exporting models to ONNX. Microsoft provides tools within the Visual Studio Code AI Toolkit to simplify this conversion process.8 This ensures that regardless of how the model was originally trained, it can be consumed by the ONNX Runtime.  
2. **Step 2: Model Optimization:** This is a critical step for on-device deployment. A raw, unoptimized model can be several gigabytes in size and consume significant memory, making it unsuitable for distribution with a desktop application. Optimization involves techniques like quantization and graph pruning. Quantization reduces the precision of the model's weights (e.g., from 32-bit floats to 4-bit integers), which dramatically reduces the model's file size and memory footprint while often improving inference speed with minimal impact on accuracy.22 Frameworks like Olive, which is powered by DirectML, are designed specifically for this purpose.1 This optimization is essential for creating a model that is small enough for easy distribution and performant enough to run on resource-constrained user hardware.  
3. **Step 3: Model Compilation:** The final step happens on the end-user's machine. When an ONNX model is loaded for the first time, the selected execution provider (e.g., DirectML) performs a final, hardware-specific compilation of the ONNX model graph.21 It applies optimizations like operator fusion (combining multiple operations into a single, more efficient one) to create a highly optimized representation for the specific underlying hardware. This compilation can be a time-consuming process, potentially taking several minutes.21 This is a one-time cost per machine, but it has significant user experience implications that must be carefully managed in the application's design, as will be discussed in Section 6\.

### **2.4 Key Implications for Local Deployment**

The architecture and capabilities of the Windows AI platform have profound implications for a FOSS project considering on-device AI.

First, Microsoft's deep and sustained investment in the on-device stack represents a strategic platform play to commoditize local AI development. By solving the difficult problems of hardware fragmentation 8 and dependency management 12, and by bundling the necessary runtimes and abstractions directly into the operating system, Microsoft is fundamentally lowering the barrier to entry for all developers. This fosters a virtuous cycle: simplified development leads to more AI-infused applications, which in turn drives consumer demand for AI-capable hardware like Copilot+ PCs.2 For this FOSS project, this means it is not adopting a niche or risky technology. Instead, it is aligning with a core, long-term strategy of the platform vendor, which guarantees robust future support, continuous performance improvements via OS updates, and a rapidly expanding user base with hardware that is optimized for the application's features.

Second, it is crucial to understand the nuance between "works everywhere" and "works best." The primary promise of Windows ML is hardware agnosticism—the ability to write code once and have it run across the entire Windows ecosystem.8 However, real-world performance is not uniform. While Windows ML provides full TensorRT acceleration for NVIDIA GPUs 12, community benchmarks and reports suggest a performance delta can exist between the abstracted DirectML execution provider and native, vendor-specific toolchains on other hardware. For example, one analysis noted that DirectML on an AMD GPU could be 50-75% slower than a dedicated ROCm implementation running in the Windows Subsystem for Linux (WSL).20 This is not a failure of the platform but a predictable trade-off. The immense strategic benefit of reaching the entire Windows market of hundreds of millions of devices with a single codebase 8 far outweighs the drawback of not achieving the absolute peak theoretical performance on every single hardware configuration. The development and testing strategy for the project should therefore focus on establishing a practical performance baseline on a representative range of common, non-enthusiast hardware (e.g., integrated Intel GPUs, older NVIDIA cards, AMD APUs), rather than optimizing solely for a high-end developer workstation. The goal is a good experience for everyone, not a perfect experience for a select few.

| Technology | Abstraction Level | Primary Role | Key Benefit for FOSS Project |
| :---- | :---- | :---- | :---- |
| **Windows ML** | High-Level API (WinRT) | Simplifies development by abstracting hardware, managing dependencies, and selecting the best processor (CPU/GPU/NPU) for the job. | Radically reduces development complexity and application size. Eliminates the need for developers to bundle and maintain the AI runtime.8 |
| **ONNX Runtime (ORT)** | Inference Engine (C++/C\#/Python) | A high-performance, cross-platform engine that loads, optimizes, and executes models in the open ONNX format. | Provides a robust, battle-tested, and performant foundation that is guaranteed to have long-term support as a core Microsoft technology.14 |
| **DirectML** | Hardware Acceleration API (DirectX 12\) | A low-level API that provides a single, unified interface for accelerating AI workloads on any DirectX 12-capable GPU or NPU from any vendor. | Solves the hardware fragmentation problem. Allows the project to achieve broad hardware acceleration across all major vendors with a single codebase.16 |

Table 1: Comparison of Windows On-Device AI Technologies

## **Section 3: The Cloud Paradigm: AI Inference as a Utility Service**

The alternative to on-device processing is to leverage the immense power of cloud-based AI models. This paradigm treats AI inference as a utility, accessible via a simple API call, and offers access to models of a scale and capability that are currently impossible to run on consumer hardware. However, this power comes at a significant and, for a FOSS project, prohibitive cost.

### **3.1 Market Landscape and Pricing Models**

The market for cloud AI is dominated by a few major players, most notably Microsoft with its Azure AI platform 23 and OpenAI with its widely used API.5 Other specialized platforms like Fireworks AI 26 and DeepInfra 27 also offer competitive inference services.

The dominant pricing model across all these providers is pay-per-token. This is a consumption-based model where the developer is billed for the amount of data processed by the model.4 The cost is calculated based on two distinct components:

* **Input Tokens:** The number of tokens sent to the model. In a Retrieval-Augmented Generation (RAG) system for technical support, this includes not only the user's direct query but also all the contextual information retrieved from the knowledge base that is "augmented" to the prompt.  
* **Output Tokens:** The number of tokens generated by the model in its response.

A "token" is roughly equivalent to four characters of text.29 This granular, per-token pricing means that every single interaction a user has with the AI feature directly translates into a cost for the developer. To establish a concrete baseline for analysis, the pricing for small, efficient models suitable for a technical support task is critical. For example, Microsoft's own Phi-4-mini model, when hosted on Azure, costs approximately $0.000075 per 1,000 input tokens and $0.0003 per 1,000 output tokens.30 OpenAI's comparable GPT-4o-mini model is priced at $0.15 per 1 million input tokens and $0.60 per 1 million output tokens.31 While these per-token costs appear minuscule, they accumulate with alarming speed at scale.

### **3.2 The Hidden Ledger of Cloud Costs**

A frequent and costly mistake in project planning is to focus solely on the advertised per-token API fees. In production, a significant portion of the total cloud bill—often 60% to 80%—can come from these "hidden" or overlooked costs.3

* **Data Transfer & Storage:** A RAG system requires a knowledge base. If this knowledge base is stored in the cloud, there are ongoing costs for that storage. Furthermore, moving data between cloud regions or out of the cloud (egress) incurs data transfer fees, which are typically around $0.09–$0.12 per gigabyte.3 These costs, while small individually, can accumulate significantly over time.  
* **The Training vs. Inference Cost Misconception:** There is a common strategic error in budgeting for AI projects: focusing too heavily on the visible, often large, one-time cost of model training, while underestimating the long-term cost of inference.3 Training is a discrete event. Inference, especially for a widely used application, is a continuous, 24/7 process. Over the lifetime of an application, the cumulative cost of millions or billions of inference calls will almost always dwarf the initial training cost.3  
* **Non-Linear Cost Scaling:** Traditional software costs often scale in a predictable, linear fashion. AI workloads, however, can exhibit non-linear cost behavior. A sudden increase in user traffic can create bottlenecks in compute, memory, or I/O, forcing the system to provision more expensive, higher-tier resources. This can cause costs to jump unexpectedly rather than scaling smoothly with usage, making accurate budget forecasting extremely difficult.3

### **3.3 Core Trade-offs: The Allure of Power vs. the Peril of Dependency**

The decision to use a cloud-based model involves a clear set of trade-offs between capability and control.

#### **Benefits of the Cloud Paradigm**

The primary allure of the cloud is immediate access to state-of-the-art, extremely powerful Large Language Models (LLMs) that are far beyond the capabilities of any current consumer hardware. These models offer superior reasoning, language understanding, and generation quality. Furthermore, the cloud provider manages all aspects of hardware, maintenance, and scalability, allowing the developer to focus solely on the application logic.26 For short-term or dynamic workloads, the pay-as-you-go model can be advantageous, eliminating the need for large upfront capital investment in hardware.9

#### **Drawbacks of the Cloud Paradigm**

Despite the power, the drawbacks for a FOSS project are severe and, ultimately, decisive.

* **Latency:** Every API call involves a network round-trip. This unavoidable delay, which can range from hundreds of milliseconds to several seconds depending on network conditions and server load, introduces a noticeable lag into the user experience. An application feature that feels sluggish and unresponsive is a significant usability flaw compared to the near-instantaneous feedback of a local model.6  
* **Privacy & Data Sovereignty:** This is a major concern. To use a cloud API, the application must send user queries and any sensitive contextual data (which could include file paths, error logs, or system information in a technical support scenario) over the internet to a third-party service.6 This raises significant privacy and data security issues. Many users are uncomfortable with their data leaving their machine, and for enterprise or security-conscious users, it can be an absolute non-starter.33  
* **Vendor Lock-in & Price Volatility:** Building an application's core functionality on a specific proprietary API creates a powerful dependency, also known as vendor lock-in.9 The cloud provider has unilateral control over the service. They can change the pricing model, alter the model's capabilities, deprecate the API version the application relies on, or even go out of business. Any of these events would force the FOSS project to undertake costly and time-consuming rework to adapt or migrate to a different service. This introduces a level of strategic risk that is antithetical to the stability and longevity required for an open-source project.

### **3.4 Key Implications for Cloud Deployment**

For a FOSS project, the implications of the cloud model's structure are profound and lead to two inescapable conclusions.

First, the pay-per-query cost model is fundamentally unsustainable for a non-monetized application. The core financial structure of a FOSS project is that it generates no revenue. A cloud API, by its very nature, generates a recurring operational cost that is directly proportional to the application's usage.4 This creates a perverse and fatal dynamic: the more successful and widely adopted the application becomes, the greater the developer's financial liability grows. An application with thousands of active users could easily generate a monthly bill of thousands of dollars, a cost that no volunteer developer or small community can bear. The only way a cloud-based model could be viable is if the cost is passed directly to the end-user through a "Bring Your Own Key" (BYOK) system. This would require users to have their own paid cloud accounts and provide their personal API keys to the application. While technically feasible, this drastically alters the nature of the feature. It is no longer a seamless, built-in tool but a complex integration reserved for a small subset of advanced, paying users, which undermines the goal of providing a free and accessible application.

Second, the project would be building on a foundation of "venture capital-subsidized" pricing, which represents an unacceptable strategic risk. Multiple analyses and reports suggest that the current, seemingly low prices for public AI APIs are not based on sustainable, long-term unit economics. Instead, they are artificially deflated, subsidized by billions of dollars in venture capital investment aimed at aggressive market share capture and user acquisition.33 Major players like OpenAI are reportedly operating at a significant annual loss to build the market.33 A FOSS project that builds a core dependency on these services is, in effect, building on a foundation of "market-burning cash." This is a high-stakes gamble on the future business models of third-party corporations. When the market inevitably shifts towards profitability, or when investor patience runs out, prices are not just likely, but almost certain, to "explode".33 A project dependent on this artificially low pricing could be rendered non-viable overnight by a simple update to a pricing page.

| Provider | Model | Input Price (per 1M tokens) | Output Price (per 1M tokens) | Notes |
| :---- | :---- | :---- | :---- | :---- |
| **Azure AI** | Phi-4-mini | $0.075 | $0.30 | 128K context, optimized for cost and performance.30 |
| **Azure AI** | Phi-3-small-8k-instruct | $0.15 | $0.60 | 8K context, balanced small model.30 |
| **OpenAI** | GPT-4o-mini | $0.15 | $0.60 | 128K context, highly capable small model.31 |
| **OpenAI** | GPT-4.1 nano | $0.10 | $0.40 | 1M context, fastest and most cost-effective OpenAI model.5 |

Table 2: Cloud AI Service Pricing Comparison (Illustrative)

## **Section 4: Architecting the Technical Support Solution: RAG and Model Selection**

Having established the strategic imperative for on-device inference, the next step is to define a robust technical architecture for the support feature itself. This involves designing a system that can provide accurate, relevant, and trustworthy answers, and selecting an appropriate AI model that is both capable and compatible with the FOSS distribution model.

### **4.1 The RAG Architecture for Grounded Technical Support**

The ideal architecture for a technical support bot is Retrieval-Augmented Generation (RAG). Unlike a standard chatbot that generates responses based solely on its pre-trained knowledge, a RAG system grounds its responses in a specific, trusted knowledge base. This dramatically reduces the risk of "hallucination"—the model inventing plausible but incorrect information—and ensures that the answers provided are accurate and directly relevant to the application's domain.

The RAG workflow is a multi-step process:

1. **Retrieval:** When a user submits a query (e.g., "How do I configure a CUDA provider in my C\# project?"), the system first searches a local knowledge base to find the most relevant documents. This knowledge base would contain information from sources like Microsoft's technical documentation and high-quality Stack Overflow answers.  
2. **Augmentation:** The system then combines the original user query with the content of the retrieved documents into a single, augmented prompt.  
3. **Generation:** This augmented prompt is fed to the local Small Language Model (SLM). The model is instructed to generate an answer to the user's query based *only* on the provided context.  
4. **Grounded Answer:** The model produces a final answer that is grounded in the source material. A sophisticated implementation can even include citations back to the original documents, allowing the user to verify the information.35

This architecture, conceptually similar to the components described in the Hugging Face RAG model documentation 36, transforms the SLM from a general-purpose conversationalist into a specialized expert that can reason over a curated set of trusted information.

### **4.2 Sourcing the Knowledge Base: A Pre-Processed, Local-First Approach**

A critical architectural decision for the RAG system is how to manage the knowledge base (KB). While the application could theoretically query sources like Microsoft Learn or Stack Overflow in real-time, this approach is fundamentally flawed for a distributed desktop application. Public APIs for these services have complex authentication requirements 37 and, more importantly, impose strict rate limits to prevent abuse.39 Attempting to hit these APIs live from every user's desktop would be slow, unreliable, and would quickly result in the application's shared API key or individual user IP addresses being throttled or banned.

The only architecturally sound strategy is for the FOSS project to develop and maintain a **KB pre-processing pipeline**. This pipeline, run periodically by the project maintainers, would perform the following steps:

1. **Scrape Sources:** Programmatically access and download content from official sources using their available APIs.  
   * **Microsoft Learn:** Access can be achieved through various methods, including the new Model Context Protocol (MCP) server endpoint 42, the Content Understanding REST API for multimodal content 43, or the Microsoft Graph API for  
     learningContent resources.44 These APIs provide rich, structured access to the official documentation.  
   * **Stack Overflow:** The Stack Exchange API (v2.3/v3) allows for programmatic access to questions and answers.45 The pipeline must be designed to handle the API's authentication and adhere strictly to its rate limits.39  
2. **Filter for Quality:** The raw data must be filtered to retain only high-quality, trustworthy information. For Stack Overflow, a powerful quality heuristic can be programmatically derived from the API response data. By combining the number of upvotes and whether an answer was marked as "accepted" by the original poster, a reliable quality score can be calculated. A simple formula such as quality\_score=(upvotes×10)+(is\_accepted×15) leverages the platform's own community validation (upvotes) and the original poster's confirmation of a solution (accepted answer) as a robust proxy for answer correctness and utility.47 This allows the KB creation process to automatically prioritize the most reliable solutions and discard low-quality or incorrect content.  
3. **Structure and Index:** The filtered content is then cleaned, structured, and loaded into a local, searchable index, such as a vector database. This index is optimized for fast retrieval.  
4. **Distribute:** The final, pre-processed index is then distributed with the application installer or offered as a one-time download upon first launch.

This pre-processing approach transforms the "Retrieval" step of the RAG process from a fragile, slow, rate-limited live API call into a fast, reliable, and offline-capable local database query. This is a crucial architectural decision that ensures the technical support feature is robust and performs well for all users.

### **4.3 Selecting the Right Tool: A Comparative Analysis of Permissively Licensed SLMs**

The final piece of the architecture is the local SLM itself. The choice of model must be guided by three critical factors: performance on resource-constrained hardware, suitability for the RAG task, and, most importantly, a permissive license that allows for free and open-source distribution.

#### **Primary Candidate: Microsoft's Phi-3 Family**

Microsoft's Phi-3 family of models, particularly the "mini" and "small" variants, emerges as the leading candidate for this project.

* **License:** The entire Phi family is released under the **MIT License**.50 This is a highly permissive open-source license that explicitly allows for free use, modification, distribution, and commercial use, making it perfectly suited for a FOSS project.51  
* **Performance and Size:** Phi-3 models are specifically designed to deliver state-of-the-art performance in a compact package, making them ideal for on-device and resource-constrained scenarios.50 The Phi-3-mini model, with only 3.8 billion parameters, has demonstrated strong reasoning and language understanding capabilities, often outperforming larger models on key benchmarks.53  
* **Ecosystem Fit:** This is the decisive advantage. Microsoft provides official, pre-optimized **ONNX versions of the Phi-3 models** specifically for different execution providers, including DirectML (for GPUs) and CPU.54 This direct, first-party support eliminates the complex and potentially error-prone steps of model conversion and optimization. It creates a seamless, "plug-and-play" integration path with the Windows AI stack and ONNX Runtime, dramatically reducing development friction and ensuring optimal performance.

#### **Strong Alternative: Pleias-RAG-1B**

The Pleias-RAG-1B model presents a compelling alternative, particularly due to its specialized design.

* **License:** This model is released under the **Apache 2.0 License** 35, which is also a permissive license suitable for FOSS and commercial use.60  
* **Performance and Size:** At only 1.2 billion parameters, Pleias-RAG-1B is extremely lightweight and can be readily deployed even on CPU RAM.35 Its key advantage is that it was explicitly trained and fine-tuned for RAG tasks. It includes a native, built-in capability for generating citations and grounding its answers in the provided source material, a powerful feature for a technical support bot that needs to provide verifiable information.35 It has been shown to outperform larger models on specific RAG benchmarks.  
* **Ecosystem Fit:** The primary drawback compared to Phi-3 is the lack of official, pre-optimized ONNX versions from the creators. While its permissive license allows for conversion, this would be an additional development step and responsibility for the project maintainers.

While other excellent open-source SLMs exist, such as Qwen, Llama 3, and Gemma 61, the combination of a highly permissive license, strong performance in a small package, and direct, first-party ecosystem integration makes Microsoft's Phi-3 family the most pragmatic and lowest-risk recommendation for this project.

| Feature | Microsoft Phi-3-mini-instruct | Pleias-RAG-1B |
| :---- | :---- | :---- |
| **Parameters** | 3.8 Billion | 1.2 Billion |
| **License** | MIT License 51 | Apache 2.0 License 35 |
| **Key Features** | State-of-the-art performance for its size, strong reasoning, designed for on-device use.53 | Specialized for RAG, native citation generation, strong multilingual performance, very small footprint.35 |
| **Official ONNX Availability** | Yes, with specific versions optimized for DirectML and CPU provided by Microsoft.54 | No, would require manual conversion by the developer. |
| **Primary Advantage** | Seamless, "plug-and-play" integration with the Windows AI stack and ONNX Runtime, minimizing development effort and risk. | Highly specialized for the core RAG task with built-in citation capabilities, offering potentially superior grounding. |

Table 3: Feature and License Comparison of Recommended SLMs for RAG

## **Section 5: The Definitive Cost-Benefit Analysis**

The strategic decision between local and cloud inference ultimately rests on a rigorous analysis of the total cost of ownership (TCO) and the associated financial risks. For a FOSS project, where sustainability is paramount, this analysis must be viewed through the uncompromising lens of a developer with zero recurring revenue.

### **5.1 Formalizing the FOSS Financial Constraint**

To formalize the core financial argument, one can use a simple profitability model. The net financial outcome for a software developer can be expressed as:

Developer\_Profit=Revenue−(Development\_Cost+Recurring\_OpEx)

For a free, open-source project, the Revenue term is, by definition, $0. This simplifies the equation to:

Developer\_Profit=−(Development\_Cost+Recurring\_OpEx)

In this model, the project is inherently a cost center. The Development\_Cost represents a one-time, upfront investment of time and resources, which is a common and accepted aspect of FOSS development. The Recurring\_OpEx, however, represents an ongoing financial drain. To ensure the long-term viability and survival of the project, the only variable the developer can control is to force the Recurring\_OpEx term to be as close to zero as possible. Any architectural choice that introduces a significant and growing recurring cost is, therefore, a direct threat to the project's existence.

### **5.2 TCO for Local Inference: A Developer-Centric View**

The on-device inference model aligns perfectly with the FOSS financial constraint by externalizing the primary recurring costs to the end-user.

* **Upfront Costs (Developer):** The developer's costs are almost entirely upfront. This is the capital expenditure of development time required for:  
  * Integrating the chosen SLM with the application using the Windows AI stack.  
  * Building and maintaining the knowledge base pre-processing pipeline.  
  * Designing and implementing a robust user experience for local model management (e.g., download managers, status indicators).  
    This is a one-time, predictable, and manageable investment of effort, typical of any software feature development.  
* **Recurring Costs (Developer):** For the developer, these costs are minimal to negligible. They are limited to:  
  * The bandwidth costs associated with hosting the model files and the pre-processed knowledge base index for users to download.  
  * The occasional compute costs of re-running the KB pipeline to update the content.  
    These costs are orders of magnitude lower than per-query API fees and can often be absorbed by free or low-cost hosting tiers provided by platforms like GitHub.  
* **End-User Costs (Externalized):** The significant, ongoing operational costs are borne by the end-user. These include:  
  * The cost of the hardware (CPU, GPU, NPU) required to run the application's AI features.  
  * The cost of the electricity consumed by that hardware during inference.  
    This is framed as part of the application's standard "System Requirements," a universally understood and accepted model in the software industry.1 The user provides the machine, and the software runs on it.

### **5.3 TCO Projection for Cloud Inference: An Unsustainable Financial Burden**

In stark contrast, the cloud inference model creates a direct and unsustainable financial burden on the FOSS developer. To illustrate this, a scenario-based cost projection can be built using the concrete pricing data for a cost-effective cloud model.

**Assumptions for Calculation:**

* **Model:** OpenAI's GPT-4o-mini, a capable and relatively inexpensive model.31  
* **Pricing:** $0.15 per 1 million input tokens and $0.60 per 1 million output tokens.31  
* **Average Query Size:** A realistic estimate for a RAG query is 1,500 input tokens (a 500-token user prompt plus 1,000 tokens of retrieved context) and 500 output tokens for the generated answer.  
* Cost per Single Query: The cost for one user interaction is calculated as:  
  Cost=(1,000,0001500​×$0.15)+(1,000,000500​×$0.60)  
  Cost=$0.000225+$0.000300=$0.000525

Using this per-query cost, it is possible to project the developer's monthly bill based on the application's user base and engagement. The results, as shown in Table 4, are staggering and demonstrate the exponential nature of the financial risk.

| Number of Active Users | Avg. Queries per User/Day | Total Daily Queries | Total Monthly Queries | Developer's Estimated Monthly Bill |
| :---- | :---- | :---- | :---- | :---- |
| 100 | 5 | 500 | 15,000 | **$7.88** |
| 1,000 | 5 | 5,000 | 150,000 | **$78.75** |
| 10,000 | 5 | 50,000 | 1,500,000 | **$787.50** |
| 100,000 | 5 | 500,000 | 15,000,000 | **$7,875.00** |
| 1,000,000 | 5 | 5,000,000 | 150,000,000 | **$78,750.00** |

Table 4: Scenario-Based Cloud Cost Projection for a FOSS Project

The analysis presented in Table 4 provides a stark and undeniable conclusion. Even with a modest user base of 10,000 active users, the developer would face a monthly bill approaching $800. For a successful project with 100,000 users, the cost escalates to nearly $8,000 per month. These are not one-time costs; they are a recurring, perpetual liability. For a project with no revenue stream, this is not a viable business model; it is a direct path to financial ruin. The more popular the application becomes, the faster it bankrupts its creator.

### **5.4 The Verdict: A Clear and Defensible Path Forward**

When all factors are considered, the choice becomes unequivocally clear. The on-device paradigm is not just the better option; it is the only viable option for a free, open-source application operating under the stated constraints. The cloud paradigm, despite its allure of raw power, introduces a combination of unsustainable recurring costs, unacceptable strategic risks, and significant privacy concerns that make it wholly unsuitable for this use case.

The following matrix provides a final, high-level summary of the comprehensive cost-benefit analysis, consolidating the findings from the entire report into a clear decision-making tool.

| Key Factor | On-Device (Local) Inference | Cloud API Inference |
| :---- | :---- | :---- |
| **Developer Recurring Cost** | **\++** (Near-zero; limited to hosting downloads) | **\--** (High, usage-based, and scales directly with user growth, making it financially unsustainable for FOSS) |
| **User Privacy & Security** | **\++** (Maximum privacy; all data remains on the user's device) | **\--** (Poor privacy; user queries and data are sent to a third-party, creating significant security and compliance risks) |
| **Performance & Latency** | **\++** (Very low latency; near-instantaneous response times) | **\-** (High latency due to network round-trips, leading to a less responsive user experience) |
| **Offline Capability** | **\++** (Fully functional without an internet connection) | **\--** (Completely non-functional without a stable internet connection) |
| **Raw Model Power** | **\-** (Limited to the capabilities of Small Language Models that can run on consumer hardware) | **\++** (Access to state-of-the-art, extremely large and powerful models) |
| **Maintenance Burden** | **\+** (Initial setup of KB pipeline; OS handles runtime updates via Windows ML) | **\-** (Vulnerable to API changes, pricing updates, and vendor deprecation, requiring reactive maintenance) |
| **Strategic Risk** | **\+** (Low risk; aligns with platform vendor's core strategy for on-device AI) | **\--** (High risk; dependency on volatile, VC-subsidized pricing and proprietary, third-party APIs) |

Table 5: Final Cost-Benefit Matrix: Local vs. Cloud for Open-Source Distribution

## **Section 6: Implementation Strategy and Best Practices for On-Device AI**

With the strategic decision made in favor of on-device inference, the focus shifts to a practical implementation strategy. A successful integration requires not only correct technical execution but also a carefully crafted user experience that accounts for the unique challenges of running AI models locally.

### **6.1 Integrating ONNX Runtime into a C\# Desktop Application (WPF/WinUI)**

The process of integrating a local ONNX model into a modern C\# desktop application, whether using WPF or WinUI 3, is well-documented and supported by Microsoft's tooling.15 The high-level steps are as follows:

1. **Project Setup:** The first step is to add the necessary NuGet packages to the C\# project. For the most streamlined experience that leverages the operating system's capabilities, the Microsoft.Windows.AI.MachineLearning package is recommended.21 This package provides the high-level Windows ML APIs. Alternatively, for more direct control or for applications targeting older Windows versions, the  
   Microsoft.ML.OnnxRuntime package can be used, often in conjunction with a specific execution provider package like Microsoft.ML.OnnxRuntime.DirectML.64  
2. **Model Loading and Session Initialization:** The core of the runtime is the InferenceSession object. This object is initialized with the path to the .onnx model file. Crucially, it can also be configured with SessionOptions. These options allow the developer to specify which execution provider to use. For example, to enable GPU acceleration, the code would explicitly append the DirectML Execution Provider to the session options.1 This gives the developer fine-grained control over how the model is executed.  
3. **Data Preparation (Input Tensors):** Before running inference, the input data (such as the augmented text prompt from the RAG system) must be converted into the tensor format that the model expects. This involves tokenizing the text and arranging it into a multi-dimensional array. A key performance optimization at this stage is to use methods like OrtValue.CreateTensorValueFromMemory. This allows the runtime to use the application's memory buffer directly, avoiding an extra and potentially slow data copy operation within the runtime itself.64  
4. **Asynchronous Execution and Output Processing:** Inference can be a computationally intensive process. To prevent the application's UI from freezing, the InferenceSession.RunAsync() method should always be used to execute the model on a background thread. Once the task completes, it returns a set of output tensors. The application code must then process these tensors—for example, by decoding the output tokens back into human-readable text—and display the results to the user.

### **6.2 Crafting a Robust and Professional User Experience for Local AI**

The technical implementation is only half the battle. Creating a polished and professional user experience is critical for the application's success and requires thoughtfully addressing the unique aspects of local AI.22

* **Model & KB Onboarding:** The application cannot assume that the necessary model files and the knowledge base index are present on first launch. The application should perform a check, and if these assets are missing, it must provide a clear and user-friendly download manager. This process should run in the background without blocking the rest of the application's functionality and should provide the user with clear progress indicators and an estimated time to completion.  
* **Handling Background Compilation:** As established in Section 2, the first-time, hardware-specific compilation of the ONNX model can take several minutes.21 This is a critical UX challenge. This compilation process  
  **must** be executed on a background thread to prevent the UI from becoming unresponsive. Furthermore, the application must manage user expectations by communicating what is happening. A simple, one-time notification like, *"First-time setup: Optimizing AI for your hardware. This may take a few minutes and will only happen once."* can prevent user frustration and confusion.  
* **Responsive Asynchronous Inference:** All subsequent inference calls must also be asynchronous to keep the UI responsive during processing. When the user submits a query, a clear loading indicator (e.g., a spinner, a pulsating icon, or a "thinking..." message) is essential. This provides immediate feedback that the application has received the request and is working on the response.  
* **Graceful Degradation and Failure Handling:** A robust application must anticipate and handle failures gracefully. The model initialization code should be wrapped in try-catch blocks to handle potential errors, such as the user's hardware being insufficient (e.g., running out of GPU memory) or lacking support for required features. If the AI feature fails to initialize, the application should not crash. Instead, it should gracefully disable the feature, persist this state, and clearly inform the user why the feature is unavailable (e.g., "AI features could not be enabled. Your system may not meet the minimum hardware requirements.").

### **6.3 A Note on IP Protection for FOSS+ Models**

While the core project is open-source and will use a permissively licensed model like Phi-3, it is worth considering a future scenario where the project might be forked or extended with a commercial version that uses a proprietary, fine-tuned model. In such cases, protecting the intellectual property contained within that model becomes a concern.

For a desktop application, achieving perfect security is impossible, but several techniques can be employed to deter casual reverse-engineering and model extraction. These include encrypting the model files at rest on the user's disk and only decrypting them into memory at runtime. Additionally, the core application logic that interacts with the model can be obfuscated to make it more difficult for an attacker to understand how the model is being used.65 Another advanced technique involves a hybrid approach, where the initial layers of the model run locally, but the intermediate tensor is sent to a secure server for the final stages of processing, with the result being sent back to the client. This makes the local model files incomplete and useless on their own.65 These are advanced considerations for potential future commercialization and are not an immediate necessity for the current FOSS scope.

## **Section 7: Final Recommendation and Future Outlook**

The comprehensive analysis of the financial, technical, and strategic factors surrounding the implementation of AI in a free, open-source Windows application leads to a clear and decisive conclusion. The choice of architecture will not only define the project's initial development but will also determine its long-term viability and alignment with the future of client-side computing.

### **7.1 Strategic Recommendation: A Definitive Endorsement of On-Device Inference**

This report provides a definitive and unambiguous recommendation for the **on-device inference model** as the architectural foundation for the technical support application. This is not merely the better option; it is the *only* financially sustainable and strategically sound path for a FOSS project operating under the specified constraints.

This conclusion is rooted in the evidence presented throughout this report:

* **Financial Viability:** The on-device model aligns with the FOSS financial structure by externalizing recurring operational costs to the end-user, framing them as standard system requirements. The cloud model, conversely, imposes a direct, usage-based cost on the developer that scales with popularity, creating an unsustainable financial burden that is a direct threat to the project's existence.  
* **User Privacy and Performance:** The local model offers superior user privacy by keeping all data on the user's machine and delivers a more responsive user experience by eliminating network latency.  
* **Strategic Risk Mitigation:** The on-device approach avoids the significant strategic risks of vendor lock-in and dependency on the volatile, VC-subsidized pricing of third-party cloud APIs.33  
* **Ecosystem Alignment:** By leveraging the modern Windows AI stack (Windows ML, ONNX Runtime, DirectML) and a permissively licensed, platform-optimized model like Microsoft's Phi-3, the project aligns itself with the core, long-term strategy of the platform vendor, ensuring future support and compatibility.8

### **7.2 The Hybrid Option: Architecting for Future Monetization**

While the primary recommendation is a robust, local-first implementation, a sophisticated architecture can be designed to create optionality for the future without compromising the integrity of the free product. The on-device model should be the default, free, and fully-featured experience for all users. However, the application can be architected to also support a **"Bring Your Own Key" (BYOK)** model as a premium or advanced feature.

This would involve adding a settings panel where a power user or an enterprise customer, who may already have a paid account with a cloud provider like Azure or OpenAI, can optionally enter their own API key. The application would then provide the choice to route queries to that user-funded cloud endpoint instead of the local model. This hybrid approach offers several advantages:

* It provides significant value to a subset of advanced users who may desire access to the raw power of larger models like GPT-4.  
* It costs the FOSS developer nothing to operate, as the user bears the full cost of the API calls.  
* It creates a clear and ethical pathway to a future "Pro" version or other monetization strategies without degrading or removing features from the free, local-first base product.

### **7.3 The Trajectory of On-Device AI: A Strategic Alignment with the Future**

Finally, the decision to commit to an on-device architecture is not merely a cost-saving measure for today but a strategic alignment with the clear and accelerating future direction of client-side computing. The project will benefit from three powerful, concurrent industry trends:

1. **Rapid Advancement of Small Language Models (SLMs):** The pace of innovation in SLMs is extraordinary. Models are continuously becoming more capable while shrinking in size, making them ever more suitable for local deployment.59  
2. **Proliferation of AI-Accelerated Hardware:** Dedicated AI accelerators, or NPUs, are rapidly becoming a standard component in mainstream consumer PCs, driven by initiatives like Microsoft's Copilot+.2 It is projected that by 2027, 60% of PCs shipped will feature on-device AI capabilities.6  
3. **Deepening Platform Integration:** Platform vendors like Microsoft are continuing to make deep investments in the on-device AI stack, making it easier for developers to harness this new hardware and creating a more performant and seamless experience for users.8

By choosing the on-device path, the application's performance, capabilities, and user experience will naturally and automatically improve over time as this powerful ecosystem evolves. It is a decision that ensures the project is not only sustainable today but is also well-positioned for relevance and success in the future.

## **Section 8: From Insight to Action: AI-Powered System Modification**

The true power of an AI-driven technical support tool extends beyond simply providing answers. The ultimate goal is to create an intelligent agent that can not only diagnose a problem but also, with the user's consent, take direct action to resolve it. This involves empowering the local Small Language Model (SLM) to interact with the Windows operating system by modifying configuration files, editing the registry, and adjusting UI settings. This transforms the application from a passive information provider into an active problem-solver.

### **8.1 The Agentic Leap: Enabling Tool Use with Local SLMs**

The mechanism that allows an SLM to interact with the outside world is known as **function calling** or **tool use**.66 The core concept is that the SLM does not execute code directly. Instead, it is provided with a manifest of available "tools"—which are simply C\# functions defined within the application.67

The process unfolds as follows 68:

1. **Tool Definition:** The developer defines a set of C\# functions that can perform specific actions, such as ModifyRegistryKey(string keyPath, string valueName, object value) or SetDisplayScaling(int scalePercentage). Each function is described with a name and a clear description of its purpose and parameters.69  
2. **Informing the Model:** When the user makes a request (e.g., "Increase my display scaling to 150%"), the application sends the prompt to the local SLM along with the list of available tools and their descriptions.67  
3. **Model Decision:** The SLM analyzes the user's intent and determines if any of the available tools can fulfill the request. If it finds a match, it doesn't execute the function itself. Instead, it generates a structured response, typically in JSON format, indicating which function to call and what parameters to use (e.g., {"function": "SetDisplayScaling", "parameters": {"scalePercentage": 150}}).68  
4. **Application Execution:** The C\# application parses this structured response. It then invokes the corresponding C\# function (e.g., using reflection or a pre-defined mapping) with the parameters provided by the model.68  
5. **Feedback Loop:** The application executes the function, captures the result (success or failure), and sends that result back to the SLM. The SLM can then generate a final, human-readable response for the user, such as "I have successfully set your display scaling to 150%."

Frameworks like Microsoft's Semantic Kernel and the Microsoft.Extensions.AI library are designed to streamline this process, providing abstractions that simplify defining tools and managing the interaction loop with the model.69

### **8.2 Fine-Tuning for Tool Use: Enhancing Reliability and Domain Specificity**

While a general-purpose SLM can perform basic function calling, its reliability and accuracy can be significantly improved through **fine-tuning**.72 Fine-tuning adapts a pre-trained model to a specific domain or task by training it further on a smaller, curated dataset.73

For a technical support agent, fine-tuning offers several key advantages:

* **Improved Tool Selection:** By training the model on examples of user requests and the corresponding correct tool calls, the model becomes much better at understanding user intent and selecting the appropriate function. This is particularly crucial for domain-specific tasks where the mapping between a user's natural language and a specific system function is not obvious.74  
* **Structured Output Generation:** Fine-tuning is highly effective for training models to generate reliable, structured outputs, such as the JSON required for function calls. Studies have shown that a fine-tuned SLM can outperform even much larger, general-purpose models at generating domain-specific structured data.74  
* **Reduced Hallucinations:** Fine-tuning on a specific dataset helps to ground the model's responses and reduces the likelihood of it "hallucinating" or inventing incorrect function calls or parameters.72  
* **Efficiency:** Using a smaller, fine-tuned model for a specific task is more computationally and cost-efficient than relying on a larger, general-purpose model.72 Techniques like Parameter-Efficient Fine-Tuning (PEFT), such as LoRA, allow for this specialization with minimal computational overhead.75

### **8.3 The Toolbox: Implementing System Modification Functions in C\#**

The agent's capabilities are defined by the C\# functions it can call. Here’s how the core system modification tools can be implemented.

#### **a. Configuration File Changes (e.g., INI files)**

Many Windows applications and components still use INI files for configuration. While.NET does not have a built-in INI parser as robust as its JSON or XML counterparts, this functionality can be achieved through several methods:

* **P/Invoke with kernel32.dll:** The most direct method is to use Platform Invoke (P/Invoke) to call the native Windows API functions WritePrivateProfileString and GetPrivateProfileString from kernel32.dll. This provides direct access to the standard Windows INI file handling logic.76  
* **Custom Parsing:** For more control, a custom parser can be written. This typically involves reading the file line by line, using string manipulation or regular expressions to identify section headers (e.g., \`\`) and key-value pairs (e.g., key=value).77 When editing, the application can read the entire file into memory, modify the specific line, and then write the entire content back to the file.80

#### **b. Registry Key Modification**

Modifying the Windows Registry is a powerful but potentially dangerous operation that must be handled with care. The.NET framework provides the Microsoft.Win32 namespace for this purpose.81

* **Core Classes:** The primary classes are Registry and RegistryKey. The Registry class provides static fields representing the root keys (e.g., Registry.CurrentUser, Registry.LocalMachine).81  
* **Opening and Writing:** To modify a value, you first open the desired subkey using Registry.CurrentUser.OpenSubKey(keyPath, true), with the second parameter set to true to indicate that the key should be writable.82 Once you have the  
  RegistryKey object, you can use the SetValue(valueName, value) method to create or modify a value.83 It is critical to wrap the  
  RegistryKey object in a using statement to ensure it is properly closed and disposed of.82  
* **Creating Keys:** If a key does not exist, it can be created using the CreateSubKey(subkeyName) method.83

#### **c. Changing Windows UI Settings**

Automating changes to the Windows UI itself (e.g., changing settings in the Settings app) is the most complex of these tasks. It requires using the **Microsoft UI Automation** framework.86

* **Framework:** This involves adding references to UIAutomationClient and UIAutomationTypes.86 The framework represents the entire UI as a tree of  
  AutomationElement objects.  
* **Finding Elements:** The first step is to get the AutomationElement for the target application window, often by finding its window handle (HWND).86 From there, you can traverse the automation tree to find specific controls (buttons, sliders, etc.) by their properties, such as  
  Name, ControlType, or AutomationId. Tools like Microsoft's Inspect.exe are invaluable for exploring the automation tree of an application.86  
* **Interacting with Controls:** Once an AutomationElement for a control is found, you can interact with it using **Control Patterns**. For example, a button will support the InvokePattern, which has an Invoke() method to simulate a click. A slider might support the RangeValuePattern to set its value programmatically.87

### **8.4 Security Architecture for an Agentic System**

Granting an AI agent the ability to modify system state introduces significant security risks. A robust security architecture is not optional; it is a fundamental requirement.

* **Principle of Least Privilege:** The agent must operate with the absolute minimum permissions required. Instead of giving it broad administrative rights, define granular, task-based permissions.88 For example, a function that modifies a specific registry key should only have rights to that key, not the entire registry hive.  
* **Sandboxing and Containment:** The agent's actions should be contained. For file modifications, this could mean writing to a temporary file first for user review. For registry changes, it could involve backing up the key before modification. Network segmentation can also be used to isolate the agent, preventing lateral movement if it is compromised.88  
* **Human-in-the-Loop (HITL) Approval:** For any action that modifies the system, the agent should not proceed autonomously. It must first generate a plan of action (e.g., "I will modify the following registry key: \[key path\] to set value \[value name\] to \[data\].") and present it to the user for explicit approval before execution. This is the most critical safety mechanism.89  
* **Input Validation and Sanitization:** All inputs to the agent, especially data retrieved from its knowledge base or the user, must be rigorously validated and sanitized to prevent prompt injection attacks, where a malicious user could try to trick the agent into performing unintended actions.88  
* **Auditing and Rollback:** Every action taken by the agent must be logged in detail. The system should also have robust rollback mechanisms, such as storing previous registry values or configuration file states, to allow the user to easily undo any changes made by the agent.88

By combining the power of function calling with a security-first mindset, it is possible to create a powerful and trustworthy AI agent that can safely and effectively resolve user issues.

## **Section 9: Step-by-Step Implementation Guide: Avalonia, C\#, and ONNX Runtime**

This section provides a detailed, step-by-step guide for building the proposed technical support application. It leverages the Avalonia UI framework for a modern, cross-platform user interface, and the ONNX Runtime for high-performance, on-device AI inference.

### **9.1 Prerequisites and Project Setup**

1. **Install.NET SDK:** Ensure you have the.NET 8 SDK or later installed.  
2. **Install Avalonia Templates:** Install the Avalonia project templates by running the following command in your terminal:  
   Bash  
   dotnet new install Avalonia.Templates

3. **Create the Application:** Create a new Avalonia application using the MVVM template:  
   Bash  
   dotnet new avalonia.mvvm \-o TechSupportAiApp  
   cd TechSupportAiApp

   This creates a new solution with a core project (TechSupportAiApp) and a desktop-specific project (TechSupportAiApp.Desktop).90  
4. **Install ONNX Runtime NuGet Packages:** In the main project (TechSupportAiApp), install the necessary ONNX Runtime packages. For broad GPU compatibility on Windows, use the DirectML package. For CPU-only fallback, use the base package.91  
   Bash  
   \# For GPU acceleration via DirectML  
   dotnet add package Microsoft.ML.OnnxRuntime.DirectML

   \# For CPU-only execution  
   dotnet add package Microsoft.ML.OnnxRuntime

   *Note: Ensure you only have one of these packages referenced. The DirectML package includes CPU support as a fallback. If you install both, you may encounter cryptic loading errors*.92  
5. **Add Model and Knowledge Base:** Create an Assets folder in your project. Download the optimized Phi-3 ONNX model files and place them in a subfolder (e.g., Assets/Model). Place your pre-processed knowledge base index file in the Assets folder as well. Set the "Copy to Output Directory" property for these files to "Copy if newer" in your .csproj file or Visual Studio properties pane.93

### **9.2 Core Application Structure (MVVM)**

The Avalonia MVVM template provides a solid foundation. The key components are:

* **Views:** XAML files that define the UI (e.g., MainWindow.axaml, ChatView.axaml). They should contain minimal code-behind, focusing only on UI-specific logic.90  
* **ViewModels:** C\# classes that contain the application logic and UI state (e.g., MainWindowViewModel.cs, ChatViewModel.cs). They expose properties and commands that the Views bind to.94 ViewModels should implement  
  INotifyPropertyChanged (or inherit from a base class that does, like ObservableObject from the CommunityToolkit.Mvvm library) to notify the UI of property changes.  
* **Models:** C\# classes that represent the application's data (e.g., a ChatMessage class with Content and Role properties).  
* **Services:** C\# classes that encapsulate specific functionalities, such as the AI inference logic. This keeps the ViewModels clean and focused on presentation logic. We will create an InferenceService.cs.

### **9.3 Integrating the ONNX Runtime for Local Inference**

Create a dedicated InferenceService.cs class to handle all interactions with the ONNX Runtime. This service will be injected into your ChatViewModel.

C\#

// In InferenceService.cs  
using Microsoft.ML.OnnxRuntime;  
using Microsoft.ML.OnnxRuntime.Tensors;  
using System;  
using System.Collections.Generic;  
using System.Linq;  
using System.Threading.Tasks;

public class InferenceService : IDisposable  
{  
    private readonly InferenceSession \_session;

    public InferenceService(string modelPath)  
    {  
        // Use SessionOptions to configure the execution provider (e.g., DirectML)  
        var sessionOptions \= new SessionOptions();  
        sessionOptions.AppendExecutionProvider\_DML(); // For DirectML GPU acceleration  
        // Or sessionOptions.AppendExecutionProvider\_CPU(); for CPU

        \_session \= new InferenceSession(modelPath, sessionOptions);  
    }

    public async Task\<string\> GetResponseAsync(string prompt)  
    {  
        // This is a simplified example. Production code would involve a more  
        // complex tokenization and generation loop.  
        return await Task.Run(() \=\>  
        {  
            // 1\. Tokenize the input prompt  
            // This requires a tokenizer specific to the model (e.g., from Hugging Face)  
            // For simplicity, we'll represent this as a placeholder.  
            var inputTokens \= Tokenize(prompt);  
            var inputTensor \= new DenseTensor\<long\>(inputTokens, new { 1, inputTokens.Length });

            // 2\. Prepare inputs for the model  
            var inputs \= new List\<NamedOnnxValue\>  
            {  
                NamedOnnxValue.CreateFromTensor("input\_ids", inputTensor)  
            };

            // 3\. Run inference  
            // The using statement is crucial to dispose of native memory  
            using var outputs \= \_session.Run(inputs);

            // 4\. Process the output tensor  
            var outputTensor \= outputs.FirstOrDefault()?.AsTensor\<long\>();  
            if (outputTensor \== null)  
            {  
                return "Error: Could not get a response from the model.";  
            }

            // 5\. Decode the output tokens back to a string  
            string responseText \= Decode(outputTensor.ToArray());  
            return responseText;  
        });  
    }

    // Placeholder for tokenizer logic  
    private long Tokenize(string text) \=\> new long { 1, 2, 3 };

    // Placeholder for decoder logic  
    private string Decode(long tokens) \=\> "This is a response from the local AI.";

    public void Dispose()  
    {  
        \_session?.Dispose();  
    }  
}

**Important:** The InferenceSession and any OrtValue objects manage native memory and **must** be disposed of correctly to prevent memory leaks. Use using statements wherever possible.95

### **9.4 Building the Chat UI in Avalonia**

In your ChatView.axaml, create a simple chat interface.

XML

\<UserControl xmlns\="https://github.com/avaloniaui"  
             xmlns:x\="http://schemas.microsoft.com/winfx/2006/xaml"  
             x:Class\="TechSupportAiApp.Views.ChatView"\>  
  \<Grid RowDefinitions\="\*,Auto"\>  
    \<ScrollViewer Grid.Row\="0"\>  
      \<ItemsControl ItemsSource\="{Binding ChatMessages}"\>  
        \<ItemsControl.ItemTemplate\>  
          \<DataTemplate\>  
            \<Border Classes.User\="{Binding IsUserMessage}"  
                    Classes.Assistant\="{Binding IsAssistantMessage}"  
                    Margin\="5" Padding\="10" CornerRadius\="8"\>  
              \<TextBlock Text\="{Binding Content}" TextWrapping\="Wrap" /\>  
            \</Border\>  
          \</DataTemplate\>  
        \</ItemsControl.ItemTemplate\>  
      \</ItemsControl\>  
    \</ScrollViewer\>

    \<Grid Grid.Row\="1" ColumnDefinitions\="\*,Auto" Margin\="5"\>  
      \<TextBox Grid.Column\="0" Watermark\="Ask a question..." Text\="{Binding UserInput}" /\>  
      \<Button Grid.Column\="1" Content\="Send" Command\="{Binding SendMessageCommand}" IsEnabled\="{Binding IsNotBusy}" /\>  
    \</Grid\>  
      
    \<ProgressBar IsVisible\="{Binding IsBusy}" IsIndeterminate\="True" VerticalAlignment\="Top" /\>  
  \</Grid\>  
\</UserControl\>

### **9.5 Handling Asynchronous Operations and UI Responsiveness**

The key to a responsive UI is ensuring that long-running tasks like AI inference do not block the UI thread. Avalonia, like WPF, uses a Dispatcher to marshal calls back to the UI thread.96

In your ChatViewModel.cs:

C\#

// In ChatViewModel.cs (using CommunityToolkit.Mvvm)  
using CommunityToolkit.Mvvm.ComponentModel;  
using CommunityToolkit.Mvvm.Input;  
using System.Collections.ObjectModel;  
using System.Threading.Tasks;

public partial class ChatViewModel : ObservableObject  
{  
    private readonly InferenceService \_inferenceService;

    \[ObservableProperty\]  
    private string \_userInput;

    \[ObservableProperty\]  
     
    private bool \_isBusy;

    public bool IsNotBusy \=\>\!IsBusy;

    public ObservableCollection\<ChatMessage\> ChatMessages { get; } \= new();

    public ChatViewModel()  
    {  
        // In a real app, use Dependency Injection to provide the service  
        \_inferenceService \= new InferenceService("Assets/Model/phi-3-mini-4k-instruct.onnx");  
    }

     
    private async Task SendMessageAsync()  
    {  
        if (string.IsNullOrWhiteSpace(UserInput) |

| IsBusy)  
        {  
            return;  
        }

        var userMessage \= UserInput;  
        UserInput \= string.Empty; // Clear the input box

        ChatMessages.Add(new ChatMessage { Content \= userMessage, IsUserMessage \= true });  
        IsBusy \= true;

        try  
        {  
            // Run inference on a background thread  
            var response \= await \_inferenceService.GetResponseAsync(userMessage);  
              
            // Update the UI on the UI thread  
            ChatMessages.Add(new ChatMessage { Content \= response, IsAssistantMessage \= true });  
        }  
        catch (Exception ex)  
        {  
            ChatMessages.Add(new ChatMessage { Content \= $"Error: {ex.Message}", IsAssistantMessage \= true });  
        }  
        finally  
        {  
            IsBusy \= false;  
        }  
    }  
}

This implementation uses async/await to run the GetResponseAsync method without blocking the UI. The IsBusy property is used to disable the "Send" button and show a progress bar while the model is processing, providing clear feedback to the user.97 Avalonia's data binding system automatically handles updating the UI from the ViewModel's properties.98

#### **Works cited**

1. Locally Executing AI Models \- devmio, accessed July 6, 2025, [https://devm.io/machine-learning/ai-audio-local-microsoft](https://devm.io/machine-learning/ai-audio-local-microsoft)  
2. FAQs about using AI in Windows apps | Microsoft Learn, accessed July 6, 2025, [https://learn.microsoft.com/en-us/windows/ai/faq](https://learn.microsoft.com/en-us/windows/ai/faq)  
3. The Hidden Cost of AI in the Cloud \- CloudOptimo, accessed July 6, 2025, [https://www.cloudoptimo.com/blog/the-hidden-cost-of-ai-in-the-cloud/](https://www.cloudoptimo.com/blog/the-hidden-cost-of-ai-in-the-cloud/)  
4. Everything you wanted to know about Azure OpenAI Pricing | by ECF Data, LLC | Medium, accessed July 6, 2025, [https://medium.com/@ecfdataus/everything-you-wanted-to-know-about-azure-openai-pricing-64b1e1f3a833](https://medium.com/@ecfdataus/everything-you-wanted-to-know-about-azure-openai-pricing-64b1e1f3a833)  
5. API Pricing \- OpenAI, accessed July 6, 2025, [https://openai.com/api/pricing/](https://openai.com/api/pricing/)  
6. Accelerating AI development with Windows-based AI workstations, accessed July 6, 2025, [https://blogs.windows.com/windowsdeveloper/2025/05/19/accelerating-ai-development-with-windows-based-ai-workstations/](https://blogs.windows.com/windowsdeveloper/2025/05/19/accelerating-ai-development-with-windows-based-ai-workstations/)  
7. Understanding inference cost in AI: A comprehensive guide \- BytePlus, accessed July 6, 2025, [https://www.byteplus.com/en/topic/517129](https://www.byteplus.com/en/topic/517129)  
8. What is Windows ML | Microsoft Learn, accessed July 6, 2025, [https://learn.microsoft.com/en-us/windows/ai/new-windows-ml/overview](https://learn.microsoft.com/en-us/windows/ai/new-windows-ml/overview)  
9. On-Premise vs Cloud: Generative AI Total Cost of Ownership ..., accessed July 6, 2025, [https://lenovopress.lenovo.com/lp2225-on-premise-vs-cloud-generative-ai-total-cost-of-ownership](https://lenovopress.lenovo.com/lp2225-on-premise-vs-cloud-generative-ai-total-cost-of-ownership)  
10. The dust is settling with AI on Windows: AI Foundry, Windows ML, and more, accessed July 6, 2025, [https://www.techzine.eu/news/applications/131547/the-dust-is-settling-with-ai-on-windows-ai-foundry-windows-ml-and-more/](https://www.techzine.eu/news/applications/131547/the-dust-is-settling-with-ai-on-windows-ai-foundry-windows-ml-and-more/)  
11. What is Windows AI Foundry? | Microsoft Learn, accessed July 6, 2025, [https://learn.microsoft.com/en-us/windows/ai/overview](https://learn.microsoft.com/en-us/windows/ai/overview)  
12. Introducing Windows ML: The future of machine learning development on Windows, accessed July 6, 2025, [https://blogs.windows.com/windowsdeveloper/2025/05/19/introducing-windows-ml-the-future-of-machine-learning-development-on-windows/](https://blogs.windows.com/windowsdeveloper/2025/05/19/introducing-windows-ml-the-future-of-machine-learning-development-on-windows/)  
13. Extending the Reach of Windows ML and DirectML \- Windows Developer Blog, accessed July 6, 2025, [https://blogs.windows.com/windowsdeveloper/2020/03/18/extending-the-reach-of-windows-ml-and-directml/](https://blogs.windows.com/windowsdeveloper/2020/03/18/extending-the-reach-of-windows-ml-and-directml/)  
14. ONNX Runtime | Home, accessed July 6, 2025, [https://onnxruntime.ai/](https://onnxruntime.ai/)  
15. onnxruntime \- ONNX Runtime, accessed July 6, 2025, [https://onnxruntime.ai/docs/](https://onnxruntime.ai/docs/)  
16. Introduction to DirectML | Microsoft Learn, accessed July 6, 2025, [https://learn.microsoft.com/en-us/windows/ai/directml/dml](https://learn.microsoft.com/en-us/windows/ai/directml/dml)  
17. Windows \- DirectML | onnxruntime, accessed July 6, 2025, [https://onnxruntime.ai/docs/execution-providers/DirectML-ExecutionProvider.html](https://onnxruntime.ai/docs/execution-providers/DirectML-ExecutionProvider.html)  
18. microsoft/DirectML: DirectML is a high-performance, hardware-accelerated DirectX 12 library for machine learning. DirectML provides GPU acceleration for common machine learning tasks across a broad range of supported hardware and drivers, including all DirectX 12-capable GPUs from vendors such as AMD, Intel, NVIDIA, and Qualcomm. \- GitHub, accessed July 6, 2025, [https://github.com/microsoft/DirectML](https://github.com/microsoft/DirectML)  
19. DirectML, accessed July 6, 2025, [https://microsoft.github.io/DirectML/](https://microsoft.github.io/DirectML/)  
20. The more things change, the more they stay the same : r/LocalLLaMA \- Reddit, accessed July 6, 2025, [https://www.reddit.com/r/LocalLLaMA/comments/1l5g36v/the\_more\_things\_change\_the\_more\_they\_stay\_the\_same/](https://www.reddit.com/r/LocalLLaMA/comments/1l5g36v/the_more_things_change_the_more_they_stay_the_same/)  
21. Run ONNX models with Windows ML \- Learn Microsoft, accessed July 6, 2025, [https://learn.microsoft.com/en-us/windows/ai/new-windows-ml/run-onnx-models](https://learn.microsoft.com/en-us/windows/ai/new-windows-ml/run-onnx-models)  
22. Implementing Local AI: A Step-by-Step Guide \- DockYard, accessed July 6, 2025, [https://dockyard.com/blog/2025/03/20/implementing-local-ai-step-by-step-guide](https://dockyard.com/blog/2025/03/20/implementing-local-ai-step-by-step-guide)  
23. Azure Pricing Overview, accessed July 6, 2025, [https://azure.microsoft.com/en-us/pricing](https://azure.microsoft.com/en-us/pricing)  
24. Azure AI Foundry \- Pricing, accessed July 6, 2025, [https://azure.microsoft.com/en-us/pricing/details/ai-foundry/](https://azure.microsoft.com/en-us/pricing/details/ai-foundry/)  
25. API Platform \- OpenAI, accessed July 6, 2025, [https://openai.com/api/](https://openai.com/api/)  
26. Fireworks AI \- Fastest Inference for Generative AI, accessed July 6, 2025, [https://fireworks.ai/](https://fireworks.ai/)  
27. Top 10 AI Inference Platforms in 2025 \- DEV Community, accessed July 6, 2025, [https://dev.to/lina\_lam\_9ee459f98b67e9d5/top-10-ai-inference-platforms-in-2025-56kd](https://dev.to/lina_lam_9ee459f98b67e9d5/top-10-ai-inference-platforms-in-2025-56kd)  
28. OpenAI API Pricing and How to Calculate Cost Automatically | by Roobia William | Medium, accessed July 6, 2025, [https://roobia.medium.com/openai-api-pricing-and-how-to-calculate-cost-automatically-e20e108eabdb](https://roobia.medium.com/openai-api-pricing-and-how-to-calculate-cost-automatically-e20e108eabdb)  
29. Azure OpenAI Cost Calculator | Calculate AI Costs for LLM Model | Microsoft \- ClearPeople, accessed July 6, 2025, [https://www.clearpeople.com/en/atlas-features/ai-cost-calculator](https://www.clearpeople.com/en/atlas-features/ai-cost-calculator)  
30. Azure AI Foundry Models Pricing, accessed July 6, 2025, [https://azure.microsoft.com/en-us/pricing/details/phi-3/](https://azure.microsoft.com/en-us/pricing/details/phi-3/)  
31. How to Calculate OpenAI API Price for GPT-4, GPT-4o and GPT-3.5 Turbo? \- Analytics Vidhya, accessed July 6, 2025, [https://www.analyticsvidhya.com/blog/2024/12/openai-api-cost/](https://www.analyticsvidhya.com/blog/2024/12/openai-api-cost/)  
32. OpenAI API Pricing Calculator \- GPT for Work, accessed July 6, 2025, [https://gptforwork.com/tools/openai-chatgpt-api-pricing-calculator](https://gptforwork.com/tools/openai-chatgpt-api-pricing-calculator)  
33. The Misleading Costs of Private vs Public Inference | by John Boero ..., accessed July 6, 2025, [https://medium.com/terasky/the-misleading-costs-of-private-vs-public-inference-be4292729910](https://medium.com/terasky/the-misleading-costs-of-private-vs-public-inference-be4292729910)  
34. On-Premise vs Cloud: Generative AI Total Cost of Ownership \- Lenovo Press, accessed July 6, 2025, [https://lenovopress.lenovo.com/lp2225.pdf](https://lenovopress.lenovo.com/lp2225.pdf)  
35. PleIAs/Pleias-RAG-1B · Hugging Face, accessed July 6, 2025, [https://huggingface.co/PleIAs/Pleias-RAG-1B](https://huggingface.co/PleIAs/Pleias-RAG-1B)  
36. RAG \- Hugging Face, accessed July 6, 2025, [https://huggingface.co/docs/transformers/model\_doc/rag](https://huggingface.co/docs/transformers/model_doc/rag)  
37. Microsoft identity platform documentation, accessed July 6, 2025, [https://learn.microsoft.com/en-us/entra/identity-platform/](https://learn.microsoft.com/en-us/entra/identity-platform/)  
38. Prerequisites to programmatically access analytics data \- Partner Center | Microsoft Learn, accessed July 6, 2025, [https://learn.microsoft.com/en-us/partner-center/insights/insights-programmatic-prerequisites](https://learn.microsoft.com/en-us/partner-center/insights/insights-programmatic-prerequisites)  
39. Throttles \- Stack Exchange API, accessed July 6, 2025, [https://api.stackexchange.com/docs/throttle](https://api.stackexchange.com/docs/throttle)  
40. The Complete Rate-Limiting Guide \- Meta Stack Exchange, accessed July 6, 2025, [https://meta.stackexchange.com/questions/164899/the-complete-rate-limiting-guide](https://meta.stackexchange.com/questions/164899/the-complete-rate-limiting-guide)  
41. What is "quota\_max" and "quota\_remaining" in api.stackexchange.com/2.2/users API? \- Meta Stack Overflow, accessed July 6, 2025, [https://meta.stackoverflow.com/questions/356419/what-is-quota-max-and-quota-remaining-in-api-stackexchange-com-2-2-users-api](https://meta.stackoverflow.com/questions/356419/what-is-quota-max-and-quota-remaining-in-api-stackexchange-com-2-2-users-api)  
42. MicrosoftDocs/mcp \- GitHub, accessed July 6, 2025, [https://github.com/MicrosoftDocs/mcp](https://github.com/MicrosoftDocs/mcp)  
43. Quickstart: Use Azure AI Content Understanding REST API \- Learn Microsoft, accessed July 6, 2025, [https://learn.microsoft.com/en-us/azure/ai-services/content-understanding/quickstart/use-rest-api](https://learn.microsoft.com/en-us/azure/ai-services/content-understanding/quickstart/use-rest-api)  
44. learningContent resource type \- Microsoft Graph v1.0, accessed July 6, 2025, [https://learn.microsoft.com/en-us/graph/api/resources/learningcontent?view=graph-rest-1.0](https://learn.microsoft.com/en-us/graph/api/resources/learningcontent?view=graph-rest-1.0)  
45. Stack Overflow for Teams API v3, accessed July 6, 2025, [https://stackoverflowteams.help/en/articles/7913768-stack-overflow-for-teams-api-v3](https://stackoverflowteams.help/en/articles/7913768-stack-overflow-for-teams-api-v3)  
46. Stack Overflow for Teams API v2.3, accessed July 6, 2025, [https://stackoverflowteams.help/en/articles/4385859-stack-overflow-for-teams-api-v2-3](https://stackoverflowteams.help/en/articles/4385859-stack-overflow-for-teams-api-v2-3)  
47. How is Stack Overflow's reputation score calculated? \- Quora, accessed July 6, 2025, [https://www.quora.com/How-is-Stack-Overflows-reputation-score-calculated](https://www.quora.com/How-is-Stack-Overflows-reputation-score-calculated)  
48. Reputation and Voting \- Stack Overflow for Teams Help Center, accessed July 6, 2025, [https://stackoverflowteams.help/en/articles/8775594-reputation-and-voting](https://stackoverflowteams.help/en/articles/8775594-reputation-and-voting)  
49. Accepted Answer Vs Voted Answers \- Meta Stack Overflow, accessed July 6, 2025, [https://meta.stackoverflow.com/questions/254790/accepted-answer-vs-voted-answers](https://meta.stackoverflow.com/questions/254790/accepted-answer-vs-voted-answers)  
50. Phi Open Models \- Small Language Models \- Microsoft Azure, accessed July 6, 2025, [https://azure.microsoft.com/en-us/products/phi](https://azure.microsoft.com/en-us/products/phi)  
51. LICENSE · microsoft/Phi-3-mini-4k-instruct-onnx at main \- Hugging Face, accessed July 6, 2025, [https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-onnx/blob/main/LICENSE](https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-onnx/blob/main/LICENSE)  
52. Microsoft Launches Open-Source Phi-3.5 Models for Advanced AI Development \- InfoQ, accessed July 6, 2025, [https://www.infoq.com/news/2024/08/microsoft-phi-3-5/](https://www.infoq.com/news/2024/08/microsoft-phi-3-5/)  
53. Phi-3 is a family of lightweight 3B (Mini) and 14B (Medium) state-of-the-art open models by Microsoft. \- Ollama, accessed July 6, 2025, [https://ollama.com/library/phi3](https://ollama.com/library/phi3)  
54. microsoft/Phi-3-mini-128k-instruct \- Hugging Face, accessed July 6, 2025, [https://huggingface.co/microsoft/Phi-3-mini-128k-instruct](https://huggingface.co/microsoft/Phi-3-mini-128k-instruct)  
55. Phi-3-mini instruct (128k) · GitHub Models, accessed July 6, 2025, [https://github.com/marketplace/models/azureml/Phi-3-mini-128k-instruct](https://github.com/marketplace/models/azureml/Phi-3-mini-128k-instruct)  
56. microsoft/phi-3-medium-4k-instruct | Run with an API on Replicate, accessed July 6, 2025, [https://replicate.com/microsoft/phi-3-medium-4k-instruct](https://replicate.com/microsoft/phi-3-medium-4k-instruct)  
57. Get started with Phi3 and other language models in your Windows app with ONNX Runtime Generative AI | Microsoft Learn, accessed July 6, 2025, [https://learn.microsoft.com/en-us/windows/ai/models/get-started-models-genai](https://learn.microsoft.com/en-us/windows/ai/models/get-started-models-genai)  
58. Creating a WinUI3 Chat application with the Phi-3 model with Semantic Kernel, accessed July 6, 2025, [https://blog.revolution.com.br/2024/10/05/creating-a-winui3-chat-application-with-the-phi-3-model-with-semantic-kernel/](https://blog.revolution.com.br/2024/10/05/creating-a-winui3-chat-application-with-the-phi-3-model-with-semantic-kernel/)  
59. They Said It Couldn't Be Done \- Hugging Face, accessed July 6, 2025, [https://huggingface.co/blog/Pclanglais/common-models](https://huggingface.co/blog/Pclanglais/common-models)  
60. Understanding Hugging Face: AI Model Licensing Guide \- Bluebash, accessed July 6, 2025, [https://www.bluebash.co/blog/understanding-hugging-face-ai-model-licensing-commercial-use/](https://www.bluebash.co/blog/understanding-hugging-face-ai-model-licensing-commercial-use/)  
61. Top 13 Small Language Models (SLMs) for 2025 \- Analytics Vidhya, accessed July 6, 2025, [https://www.analyticsvidhya.com/blog/2024/12/top-small-language-models/](https://www.analyticsvidhya.com/blog/2024/12/top-small-language-models/)  
62. Best Small LLM For Rag \- Models \- Hugging Face Forums, accessed July 6, 2025, [https://discuss.huggingface.co/t/best-small-llm-for-rag/143971](https://discuss.huggingface.co/t/best-small-llm-for-rag/143971)  
63. Top 10 Open-Source LLMs models for commercial use \- YourGPT, accessed July 6, 2025, [https://yourgpt.ai/blog/general/top-10-open-source-llms-everything-you-need-to-know](https://yourgpt.ai/blog/general/top-10-open-source-llms-everything-you-need-to-know)  
64. Get started with ONNX models in your WinUI app with ONNX Runtime \- Learn Microsoft, accessed July 6, 2025, [https://learn.microsoft.com/en-us/windows/ai/models/get-started-onnx-winui](https://learn.microsoft.com/en-us/windows/ai/models/get-started-onnx-winui)  
65. Desktop App With Proprietary local AI models : r/ycombinator \- Reddit, accessed July 6, 2025, [https://www.reddit.com/r/ycombinator/comments/1kv8zel/desktop\_app\_with\_proprietary\_local\_ai\_models/](https://www.reddit.com/r/ycombinator/comments/1kv8zel/desktop_app_with_proprietary_local_ai_models/)  
66. Introduction to function calling | Generative AI on Vertex AI \- Google Cloud, accessed July 8, 2025, [https://cloud.google.com/vertex-ai/generative-ai/docs/multimodal/function-calling](https://cloud.google.com/vertex-ai/generative-ai/docs/multimodal/function-calling)  
67. Prompting Best Practices for Tool Use (Function Calling) \- OpenAI Developer Community, accessed July 8, 2025, [https://community.openai.com/t/prompting-best-practices-for-tool-use-function-calling/1123036](https://community.openai.com/t/prompting-best-practices-for-tool-use-function-calling/1123036)  
68. Implementing function calling (tools) without frameworks? : r/LocalLLaMA \- Reddit, accessed July 8, 2025, [https://www.reddit.com/r/LocalLLaMA/comments/1cvkli4/implementing\_function\_calling\_tools\_without/](https://www.reddit.com/r/LocalLLaMA/comments/1cvkli4/implementing_function_calling_tools_without/)  
69. Quickstart \- Extend OpenAI using Tools and execute a local Function ..., accessed July 8, 2025, [https://learn.microsoft.com/en-us/dotnet/ai/quickstarts/use-function-calling](https://learn.microsoft.com/en-us/dotnet/ai/quickstarts/use-function-calling)  
70. Add chat completion services to Semantic Kernel | Microsoft Learn, accessed July 8, 2025, [https://learn.microsoft.com/en-us/semantic-kernel/concepts/ai-services/chat-completion/](https://learn.microsoft.com/en-us/semantic-kernel/concepts/ai-services/chat-completion/)  
71. Building Local AI Agents: Semantic Kernel Agent with Functions in C\# using Ollama \- Laurent Kempé, accessed July 8, 2025, [https://laurentkempe.com/2025/03/02/building-local-ai-agents-semantic-kernel-agent-with-functions-in-csharp-using-ollama/](https://laurentkempe.com/2025/03/02/building-local-ai-agents-semantic-kernel-agent-with-functions-in-csharp-using-ollama/)  
72. Fine-tuning & Inference of Small Language Models like Gemma \- Analytics Vidhya, accessed July 8, 2025, [https://www.analyticsvidhya.com/blog/2024/09/fine-tuning-inference-of-small-language-models-like-gemma/](https://www.analyticsvidhya.com/blog/2024/09/fine-tuning-inference-of-small-language-models-like-gemma/)  
73. Fine-Tuning & Small Language Models \- Prem AI Blog, accessed July 8, 2025, [https://blog.premai.io/fine-tuning-small-language-models/](https://blog.premai.io/fine-tuning-small-language-models/)  
74. Fine-Tune an SLM or Prompt an LLM? The Case of Generating Low-Code Workflows \- arXiv, accessed July 8, 2025, [https://arxiv.org/html/2505.24189v1](https://arxiv.org/html/2505.24189v1)  
75. Fine-Tuning and Benchmarking Small Language Models (SLMs): An Alternative to Foundation Models ? | by Rafael Costa de Almeida | Medium, accessed July 8, 2025, [https://medium.com/@rafaelcostadealmeida159/fine-tuning-and-benchmarking-small-language-models-slms-an-alternative-to-foundation-models-8c16d29e25f9](https://medium.com/@rafaelcostadealmeida159/fine-tuning-and-benchmarking-small-language-models-slms-an-alternative-to-foundation-models-8c16d29e25f9)  
76. c\# \- Editing an ini file \- Stack Overflow, accessed July 8, 2025, [https://stackoverflow.com/questions/23949334/editing-an-ini-file](https://stackoverflow.com/questions/23949334/editing-an-ini-file)  
77. c\# \- Reading/writing an INI file \- Stack Overflow, accessed July 8, 2025, [https://stackoverflow.com/questions/217902/reading-writing-an-ini-file](https://stackoverflow.com/questions/217902/reading-writing-an-ini-file)  
78. C\# INI File Parser : r/csharp \- Reddit, accessed July 8, 2025, [https://www.reddit.com/r/csharp/comments/1fit3t4/c\_ini\_file\_parser/](https://www.reddit.com/r/csharp/comments/1fit3t4/c_ini_file_parser/)  
79. C\# INI File Parser \- CodeProject, accessed July 8, 2025, [https://www.codeproject.com/Articles/5387487/Csharp-INI-File-Parser](https://www.codeproject.com/Articles/5387487/Csharp-INI-File-Parser)  
80. C\# \- Change a value in an .ini file \- YouTube, accessed July 8, 2025, [https://www.youtube.com/watch?v=wjde5vofXFk](https://www.youtube.com/watch?v=wjde5vofXFk)  
81. Read and Write Windows Registry to Store Data Using C\#, accessed July 8, 2025, [https://www.c-sharpcorner.com/UploadFile/f9f215/windows-registry/](https://www.c-sharpcorner.com/UploadFile/f9f215/windows-registry/)  
82. c\# \- modifying the registry key value \- Stack Overflow, accessed July 8, 2025, [https://stackoverflow.com/questions/8816178/modifying-the-registry-key-value](https://stackoverflow.com/questions/8816178/modifying-the-registry-key-value)  
83. C\# Edit Registry Keys or Values \- coding.vision, accessed July 8, 2025, [https://codingvision.net/c-edit-registry-keys-or-values](https://codingvision.net/c-edit-registry-keys-or-values)  
84. Registry.SetValue Method (Microsoft.Win32), accessed July 8, 2025, [https://learn.microsoft.com/en-us/dotnet/api/microsoft.win32.registry.setvalue?view=net-9.0](https://learn.microsoft.com/en-us/dotnet/api/microsoft.win32.registry.setvalue?view=net-9.0)  
85. Create registry key programmatically \- Stack Overflow, accessed July 8, 2025, [https://stackoverflow.com/questions/40907409/create-registry-key-programmatically](https://stackoverflow.com/questions/40907409/create-registry-key-programmatically)  
86. Getting Started with UI Automation with C\# in Windows | Fun With Testing, accessed July 8, 2025, [https://funwithtesting.wordpress.com/2016/01/24/getting-started-with-ui-automation-with-c-in-windows/](https://funwithtesting.wordpress.com/2016/01/24/getting-started-with-ui-automation-with-c-in-windows/)  
87. Automate your UI using Microsoft Automation Framework \- CodeProject, accessed July 8, 2025, [https://www.codeproject.com/Articles/141842/Automate-your-UI-using-Microsoft-Automation-Framew](https://www.codeproject.com/Articles/141842/Automate-your-UI-using-Microsoft-Automation-Framew)  
88. Securing AI agents: A guide to authentication, authorization, and ..., accessed July 8, 2025, [https://workos.com/blog/securing-ai-agents](https://workos.com/blog/securing-ai-agents)  
89. How to build a defensive AI security agent with RAG \- Anshuman Bhartiya, accessed July 8, 2025, [https://www.anshumanbhartiya.com/posts/defenseagent](https://www.anshumanbhartiya.com/posts/defenseagent)  
90. Avalonia C\# (How It Works For Developers) \- IronPDF, accessed July 8, 2025, [https://ironpdf.com/blog/net-help/avalonia-csharp/](https://ironpdf.com/blog/net-help/avalonia-csharp/)  
91. C\# \- onnxruntime \- GitHub Pages, accessed July 8, 2025, [https://oliviajain.github.io/onnxruntime/docs/get-started/with-csharp.html](https://oliviajain.github.io/onnxruntime/docs/get-started/with-csharp.html)  
92. Using Phi-3 & C\# with ONNX for text and vision samples \- .NET Blog, accessed July 8, 2025, [https://devblogs.microsoft.com/dotnet/using-phi3-csharp-with-onnx-for-text-and-vision-samples-md/](https://devblogs.microsoft.com/dotnet/using-phi3-csharp-with-onnx-for-text-and-vision-samples-md/)  
93. Tutorial: Detect objects using an ONNX deep learning model \- ML.NET \- Learn Microsoft, accessed July 8, 2025, [https://learn.microsoft.com/en-us/dotnet/machine-learning/tutorials/object-detection-onnx](https://learn.microsoft.com/en-us/dotnet/machine-learning/tutorials/object-detection-onnx)  
94. Avalonia UI \- 02 \- Data Binding \- YouTube, accessed July 8, 2025, [https://www.youtube.com/watch?v=FSS6UdUy128](https://www.youtube.com/watch?v=FSS6UdUy128)  
95. Basic C\# Tutorial | onnxruntime, accessed July 8, 2025, [https://onnxruntime.ai/docs/tutorials/csharp/basic\_csharp.html](https://onnxruntime.ai/docs/tutorials/csharp/basic_csharp.html)  
96. Avalonia's Dispatcher \- code4ward.net, accessed July 8, 2025, [https://code4ward.net/blog/2024/02/28/dispatcher/](https://code4ward.net/blog/2024/02/28/dispatcher/)  
97. Background Task : r/csharp \- Reddit, accessed July 8, 2025, [https://www.reddit.com/r/csharp/comments/vjoao2/background\_task/](https://www.reddit.com/r/csharp/comments/vjoao2/background_task/)  
98. Data Binding | Avalonia Docs, accessed July 8, 2025, [https://docs.avaloniaui.net/docs/basics/data/data-binding/](https://docs.avaloniaui.net/docs/basics/data/data-binding/)