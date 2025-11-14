# 🏗️ BuildChain Infrastructure Trust

A blockchain-powered infrastructure project management platform built on Stacks that creates transparent, milestone-based project execution with integrated contractor verification, quality assurance, and trust-based payment systems.

## 🌟 Overview

BuildChain Infrastructure Trust revolutionizes infrastructure development by establishing a decentralized ecosystem where clients, contractors, and inspectors collaborate through verified milestones, quality inspections, and automated payment releases based on project completion and quality standards.

## 🚀 Features

### 🏢 For Project Clients
- **Project Creation**: Launch infrastructure projects with detailed specifications and budgets
- **Contractor Selection**: Choose from verified contractors with transparent trust scores
- **Milestone Management**: Break projects into manageable, funded milestones
- **Quality Control**: Rate contractors and approve payments based on inspections
- **Trust Fund Management**: Secure project funding through escrow-style payments

### 👷 For Contractors
- **Professional Registration**: Register with specializations and build verified profiles
- **Project Bidding**: Access to infrastructure projects matching expertise
- **Milestone Completion**: Track progress and submit completed work for inspection
- **Trust Score Building**: Build reputation through successful project completions
- **Automated Payments**: Receive quality-based bonus payments upon milestone approval

### 🔍 For Inspectors & Platform
- **Infrastructure Inspections**: Conduct quality and safety assessments
- **Compliance Verification**: Ensure safety and regulatory compliance
- **Quality Scoring**: Rate work quality to determine payment bonuses
- **Trust Network**: Maintain platform integrity through verified inspections

## 📋 Contract Functions

### 🔍 Read-Only Functions

- `get-project(project-id)` - Retrieve complete project details and status
- `get-contractor(contractor)` - Access contractor profile, ratings, and earnings
- `get-milestone(project-id, milestone-id)` - Get specific milestone information
- `get-project-funding(project-id, funder)` - View funding contributions and status
- `get-trust-rating(project-id, rater)` - Access project quality ratings
- `get-inspection(project-id, milestone-id)` - Review inspection reports and approvals
- `get-total-projects()` - Current number of projects on platform
- `get-total-contractors()` - Total registered contractors
- `get-trust-fund-balance()` - Available trust fund balance
- `calculate-milestone-payment(budget-allocation, quality-score)` - Calculate quality-adjusted payment
- `is-project-active(project-id)` - Check if project is active and accepting work

### ✍️ Public Functions

#### 👷 Contractor Operations
- `register-contractor(name, specialty)` - Register as verified contractor
- `complete-milestone(project-id, milestone-id)` - Submit completed milestone work

#### 🏢 Client Operations
- `create-project(contractor, title, description, total-budget, deadline-blocks, project-type)` - Create new infrastructure project
- `add-milestone(project-id, title, description, budget-allocation, deadline-blocks)` - Add project milestone
- `fund-project(project-id, amount)` - Add funds to project trust account
- `release-milestone-payment(project-id, milestone-id)` - Release payment after approval
- `rate-project(project-id, contractor-rating, quality-rating, timeline-rating)` - Rate completed project
- `close-project(project-id)` - Mark project as completed

#### 🔍 Inspection & Verification
- `inspect-infrastructure(project-id, milestone-id, quality-score, safety-compliance, notes)` - Conduct official inspection
- `verify-contractor(contractor)` - Admin function to verify contractor credentials

#### 🛠️ Administrative Operations
- `update-milestone-bonus(new-bonus)` - Adjust quality bonus percentage
- `transfer-ownership(new-owner)` - Transfer platform ownership

## 🎮 Usage Examples

### 👷 Registering as a Contractor

```clarity
(contract-call? .buildchain-trust register-contractor "ABC Construction Inc" "Road Infrastructure")
```

### 🏗️ Creating an Infrastructure Project

```clarity
(contract-call? .buildchain-trust create-project 
    'SP1ABC123... 
    "Highway Bridge Repair Project"
    "Complete structural repairs and safety upgrades to Highway 101 Bridge"
    u500000
    u5000
    "bridge-repair"
)
```

### 📋 Adding Project Milestones

```clarity
(contract-call? .buildchain-trust add-milestone 
    u1 
    "Foundation Assessment"
    "Complete structural assessment and foundation repair planning"
    u100000 
    u500
)
```

### 💰 Funding a Project

```clarity
(contract-call? .buildchain-trust fund-project u1 u500000)
```

### ✅ Completing a Milestone

```clarity
(contract-call? .buildchain-trust complete-milestone u1 u1)
```

### 🔍 Inspecting Infrastructure Work

```clarity
(contract-call? .buildchain-trust inspect-infrastructure u1 u1 u85 true "Excellent foundation work, meets all safety standards")
```

### 💸 Releasing Milestone Payment

```clarity
(contract-call? .buildchain-trust release-milestone-payment u1 u1)
```

## 🏗️ Architecture

### 📊 Data Structures

#### Projects Map
Complete project lifecycle management including client, contractor, budget, timeline, and completion tracking.

#### Contractors Map
Comprehensive contractor profiles with specializations, trust scores, completed projects, and earnings history.

#### Milestones Map
Detailed milestone tracking with budget allocations, deadlines, completion status, and verification records.

#### Project Funding Map
Transparent funding records with funder contributions, timestamps, and refund status.

#### Trust Ratings Map
Multi-dimensional quality ratings covering contractor performance, work quality, and timeline adherence.

#### Infrastructure Inspections Map
Professional inspection reports with quality scores, safety compliance, approval status, and detailed notes.

### 🔢 Economic Model

- **Trust Score Range**: 0-100 (starting at 50 for new contractors)
- **Quality Bonus**: Base budget + (budget × quality score / 100)
- **Milestone Completion Bonus**: +5 trust score points (adjustable by admin)
- **Inspection Threshold**: 70+ quality score & safety compliance required for approval
- **Project Status**: 0 = closed, 1 = active and accepting work

## 🏗️ Infrastructure Project Types

### 🛣️ Transportation Infrastructure
- **Road Construction**: Highway, street, and pathway development
- **Bridge Projects**: Bridge construction, repair, and maintenance
- **Traffic Systems**: Traffic lights, signage, and safety systems

### 🏢 Building & Civil Infrastructure  
- **Commercial Construction**: Office buildings, retail spaces, warehouses
- **Residential Development**: Housing projects, apartment complexes
- **Public Facilities**: Schools, hospitals, community centers

### ⚡ Utility Infrastructure
- **Power Systems**: Electrical grid, renewable energy installations
- **Water Management**: Water treatment, distribution, sewage systems
- **Telecommunications**: Fiber optic, cellular tower installations

### 🌉 Specialized Infrastructure
- **Environmental Projects**: Green infrastructure, sustainability upgrades  
- **Industrial Facilities**: Manufacturing plants, processing facilities
- **Emergency Infrastructure**: Disaster recovery, emergency response systems

## 🛡️ Security & Trust Features

- **Milestone-Based Payments**: Funds released only after inspection approval
- **Quality-Adjusted Compensation**: Bonus payments for high-quality work
- **Multi-Party Verification**: Client, contractor, and inspector involvement
- **Trust Score System**: Reputation building through verified project completion
- **Safety Compliance**: Mandatory safety checks for all infrastructure work
- **Transparent Funding**: All funding and payment activities are publicly verifiable

## ⚠️ Error Codes

- `u400`: Invalid amount or parameter provided
- `u401`: Unauthorized access attempt
- `u402`: Insufficient funds for operation
- `u403`: Project completed or deadline passed
- `u404`: Requested resource not found
- `u405`: Milestone not ready for requested operation
- `u406`: Invalid status for operation
- `u409`: Resource already exists (duplicate)

## 🚀 Getting Started

### For Project Clients
1. **Identify Contractors**: Browse verified contractors by specialty and trust score
2. **Create Project**: Define scope, budget, timeline, and project type
3. **Add Milestones**: Break project into manageable, funded milestones
4. **Fund Project**: Transfer funds to secure trust fund account
5. **Monitor Progress**: Track milestone completion and approve payments
6. **Rate Performance**: Provide feedback to build contractor reputation

### For Contractors
1. **Register Profile**: Submit credentials, specialty, and professional information
2. **Build Trust Score**: Complete projects successfully to improve reputation
3. **Accept Projects**: Work on projects matching your expertise
4. **Complete Milestones**: Submit work for inspection and approval
5. **Earn Payments**: Receive quality-adjusted payments upon approval

### For Platform Administration
1. **Verify Contractors**: Approve contractor credentials and expertise claims
2. **Conduct Inspections**: Assess work quality and safety compliance
3. **Maintain Standards**: Ensure platform integrity through verification
4. **Adjust Parameters**: Update bonus rates and quality thresholds

## 🧪 Testing

Run the comprehensive test suite:

```bash
npm install
npm test
```

## 📊 Platform Analytics

Track infrastructure development impact through:
- Total projects funded and completed
- Contractor trust score distributions
- Quality rating trends and improvements
- Payment processing and milestone success rates
- Infrastructure project type analysis

## 🌍 Real-World Impact

BuildChain Infrastructure Trust directly supports:
- **Infrastructure Development**: Accelerating critical infrastructure projects
- **Quality Assurance**: Ensuring high standards through verified inspections
- **Contractor Development**: Building professional reputation through transparent ratings
- **Project Transparency**: Providing full visibility into project progress and funding
- **Economic Growth**: Supporting construction industry through fair, automated payments

## 📄 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Help build the future of infrastructure development! Contributions welcome for:
- Smart contract enhancements
- Quality assessment methodologies
- Trust scoring algorithms
- Inspection workflow improvements

---

**Building Trust in Infrastructure 🏗️ Built on Stacks Blockchain**