---
stand_alone: true
ipr: trust200902
cat: info # Check
submissiontype: IETF
area: OPS
wg: IVY

docname: draft-ivy-entitlements-00

title: A YANG module for entitlement inventory
abbrev: entitlement inventory
lang: en
kw:
  - entitlement
  - inventory
  - assets
  - features
author:
- role: editor # remove if not true
  ins: M. Palmero
  name: Marisol Palmero
  organization: Cisco Systems
  email: mpalmero@cisco.com
- role: editor # remove if not true
  ins: C. Cardona
  name: Camilo Cardona
  organization: NTT
  email: camilo@gin.ntt.net
- role: editor # remove if not true
  ins: D. Lopez
  name: Diego Lopez
  organization: Telefonica I+D
  email: diego.r.lopez@telefonica.com

--- abstract

This document proposes a YANG module with an inventory of entitlements. The model helps manage details about entitlements, such as  their scope, how they’re assigned, and when they expire. The model introduces the a descriptive definition of features and use restriction that can help a entitlement admistration an understanding of the state of their assets and the capabilities available across the network. 

--- middle

# Introduction

An entitlement grants specific holders the right to access particular features of one or more assets. The use of these features may be restricted in various ways, such as by duration, usage limits, or predefined conditions. Having information a centralizaed point with the state of the entitlements of the network can save time and facilitate decision making. In this document, we propose a yang model that, complementing the network inventory module, can provide the information the asset/entitlement adminstrator needs for this.

## Glosary

TODO. We need the distinction between licenses and entitlements.

## Requirements language

{::boilerplate bcp14}

## Scope of the entitlement model {#QUESTIONS}

The entitlement model aims to provide an inventory of entitlements. This includes the entitled holders and the features to which they are entitled. Additionally, it offers  information into the restrictions of the operation of the different assets (network entities and components). 

In general, this model seeks to address the following questions:

* What entitlements are administered/owned by the organization?  
* How are entitlements restricted to some assets and holders?
* What entitlements are assigned or installed on each assets?
* What constraints do the current entitlements impose in the assets functionality?
* Does the entitlement imposses any kind of global restrictions? What are they?
* What are the restrictions that each asset due to the entitlements it holds?

These points will be elaborated further in section {{ENTMODEL}}. Initially, we will delineate some aspects not covered by this model, followed by an explanation of features.

The model is designed with flexibility in mind, allowing for expansion through the utilization of tools provided by YANG.

## Out of scope elmements of the DLMO entitlement model

The realm of entitlements or licenses is inherently complex, presenting challenges in creating a model that can comprehensively encompass all scenarios without ambiguity. While we attempt to address various situations through examples and use cases, we  acknowledge that the model might not be able to cover all corner cases without ambiguity. In such cases, we recommend that implementations provide additional documentation to clarify potential ambiguities.

The current model does not aim to serve as a catalog of licenses. While it may accommodate basic scenarios, it does not aim to cover the full spectrum of license characteristics, which can vary significantly. Instead, our focus is on providing a general framework for describing relationships and answering the questions we expose in section {{QUESTIONS}}.

To clarify, here are some questions that our model does not attempt to answer:

* What are the implications of purchasing a specific entitlement?
* Which entitlement should I acquire to get a specific feature?
* Is license migration feasible?
* What features will be allowed if I install an entitlement in specific device?
* Features or restrictions that depend on each user. We are not covering this in the current version of this document, but it could be done if we expand the holders indentification.

We emphasize that the model primarily addresses the commercial utilization of features, rather than access control. For instance, if a network device cannot be configured an arbitrary network protocol (e.g. MPLS) due to licensing restrictions, this implies that the organization owning the router (the holder  in this scenario) is not permitted to utilize the MPLS feature. This distinction is separate from, for instance, the ability of an user to configure MPLS due to access control limitations.

## Features (or maybe capabilities?)

Entitlements entitle a holder to use a feature of an asset. In some cases, this feature can be simply the use of the asset itself (e.g., the use of software, the use of network equipment). However, in common cases, assets can offer a rich array of features that are subject to entitlement levels.

Under the entitlement  model, we do not attempt to model features exhaustively. Instead, we provide a descriptive definition of features, which falls under the responsibility of the model's implementers. Also, the main philosofy behind the model is to only list those features that are allowed/restricted based on the entitlements that the organization coutns with. The features under the entitlmeents model are not there to list all features available by an asset, but only those that depend on the entitlmeent state of the asset.

We'll provide examples of feature definitions in our use cases.

# Entitlements Modeling {#ENTMODEL}

The model aims to provide a framework for addressing the questions outlined in Section {{QUESTIONS}} across various use cases. In this section, we delve deeper into these questions, offering examples to demonstrate why some are more complex than initially perceived.

The entitlement model is included in Secion {{MODEL}}. We will describe how each of the questions in Section {{QUESTIONS}} are responded by the model. First, we will introduce  a toy example to show how each question can be answered. 

## Toy example for entitlement model

As a toy example for the model we'll use the next scenario: Two network elements (routers), each with a line card, and a port.  Both routers are of the same type (generic_router), which requires an entitlement to operate. The router entitlement is issued for each device specifically. The line card also requires a license to operate, and an extra license to allow for more than 100Gbps per port and breakout functionality, but they are not issued for each router.  Both routers have the generic and the line card license, but one is missing the port license, therefore the ports are limited.

The resulting json with these scenario is attached next:

~~~~ json
{::include folded_figures/toy_example.json}
~~~~
{: #toyexample title="Toy scenario for entitlement model description"}

## What entitlements are administered/owned by the organization (entitlement's inventory)?

The model should facilitate listing all entitlements associated with a set of assets under the same asset administration. In scenarios where entitlements are tied to assets, the asset itself could provide this information. Alternatively, providers may support something similar to a license server, which could house comprehensive information regarding an organization's licenses.

Within the model, all entitlements and features are listed directly under the network-inventory-entitlements container of the model.

Just by listing the entitlements, and provide their basic information, a netconf client will be able to retrieve basic inventory information of existing entitlements, without processing the more complex relationships that we will describe in the next sections.

Note that the model uses lists based on classes on multiple parts to be able to extend functionality. We will provide examples of how this can be done in posterior releases of this document.

The entitlements and features list do not specify which the assets (network elments or components) are actually assigned the entitlements, either through an installation  or a similar operation. For this, we augment the network elements form the network-inventory {{?I-D.draft-ietf-ivy-network-inventory-yang-03}} model with a new container called entitlement-information. This container  hold information of the state of entitlmenets in the asset.

The entiltment container holds a container called entitlement-attachements which relates  how the entitlement is COMMERCIALLY linked to holders or assets. Note that there is a difference between an entilement being attached to an asset and an entilement being installed in the asset. In the former, we mean that the license was issued only for one (or more) assets.  Some licenses actually can be open but have a limited number of installation, just as we have in our toy example. Other licenses might be openly contraint to geography localtion. We are not deailing with these complex cases now, but the container can be expanded for this in the future. 

In our toy example, we can extract the information in a single table. We show the summary in the next figure.

~~~~ 
{::include folded_figures/entitlement_report}
~~~~
{: #entitlmenet_report title="Entitlement report for toy case"}

Entitlements might be listed by multiple assets. For instance, a license server, functioning as an asset, might list an entitlement, while the asset entitled by the license might also list it. Proper identification of entitlements is imperative to ensure consistency across systems, enabling monitoring systems to recognize when multiple assets list the same entitlement.

Furthermore, there are cases where an authorized asset might not be aware of the covering license. Consider the scenario of a site license, wherein any device under the site may utilize a feature without explicit knowledge of the covering license. In such cases, asset awareness relies on management controls or a service license capable of listing it.

The model accommodates listing entitlements acquired by the organization but not yet applied or utilized by any actor/asset. For these "pending" entitlements, logistical constraints may arise in informing their existence, as there must be at least one element exporting the model that is aware of their existence.

Some entitlements are inherently associated with an holder, such as organization or an user. For example, a software license might be directly attached to a user. Also, the use of a network device might come with a basic license provided solely to an organization. Some entitlements could be assigned to a more abstract description of holders, such as people under a juristiction a geographical area. The model contains basic information about this, but it can be extended in the future to be more descriptive.

## What is the link between a entitlement and assets?

Entitlements and assets are linked in the model in two ways. Entitlemenets might be "attached" to assets, and assets include (or have installed) entitlements. The former is included under the network-inventory-entitlements list container, while the former is included as an augmenetation in the network element.

When an asset lists an entitlement, it means that the entitlement is installed in the asset. An entitlement that is not listed by any asset means that is not being used (even if it is attached to an asset, as we will see later).

Attaching an entitlement to one or multiple asset means that the entitlement is exclusively used by that asset. However, this is not mandatory and there are many licenses that are open and can be installed at any asset of certain type.

While attachment is optional, the model should be capable of expressing attachment in various scenarios. The model can be expanded to list to which assets an entitlement is aimed for, when this link is more vague, such as a site license (e.g., assets located in a specific site), or more open licenses (e.g., free software for all users subscribed to a streaming platform).

It's important to note that the current model does not provide information on whether an entitlement can be reassigned to other devices (e.g., fixed or floating license). Such scenarios fall under the "what if" category, which is not covered by this model.

The list of attached assets, and the assets where the entitlements are installed is included already in the figure {{entitlmenet_report}}.

## What constraints do assets, under the current entitlements, impose on the actors' use of the asset's features?

Assets provide various features, which may be restricted based on the availability of proper entitlements. A entitlement manager might be interested in the features that are not available to use on the assets, and the features that are available.

The model includes this information on the entitlement-information/feature-information/feature-use which is the entitlement-model adds to the network-elements from the network inventory model..

An entitlement  grants permission to access specific features associated with an asset. However, in some cases, there are limitations or restrictions on the use of these features. it's essential for the model to provide information on the status of the entitlement, particularly if it is at risk of being infringed upon. This can help organizations stay informed about their entitlement usage and take necessary actions to prevent potential violations or overuse of features.

All the information related to how an asset provides a feature to actors is included under the feature container wihtin the asset class, under the entitlements-info container.


~~~~ 
{::include folded_figures/feature_report}
~~~~
{: #feature_report title="Features report for toy case"}


## How are entitlements utilized? Which actors are using features backed by entilements? And in cases where the entitlements provide limits, how close the use of those features is to those limits.

~~~~ 
{::include folded_figures/asset_restrictions}
~~~~
{: #asset_restrictions title="Restrictions  report for toy case"}

# Entitlements model {#MODEL}

Here is the tree for the entitlement model.

~~~~ 
{::include folded_figures/tree}
~~~~
{: #tree title="Tree of entitlement model"}

The full entitlement model comes in the next figure.

~~~~ yang
{::include folded_figures/ietf-network-inventory-entitlements-features.yang}
~~~~
{: #full_model title="Complete entitlement model"}

# Use cases

In this section we will describe use cases, an example of how they could be modelled by the model, and show how each of the questions that we have explored in this draft can be answered by the model.

TODO in next versions.

