{
  "version": 1,
  "description": "Revenue-domain semantic override registry. Maps high-confidence user terms to exact Salesforce field/value pairs. Used to correct field misrouting (e.g. Scaleup→Region__c not Cluster__c) before SOQL compilation.",
  "overrides": [
    {
      "id": "region_scaleup",
      "terms": ["scaleup", "scaleups", "scale up", "scale-up", "scale"],
      "correctField": "Region__c",
      "correctValue": "Scaleup",
      "forbiddenFields": ["Cluster__c", "Account_Cluster__c"],
      "reason": "Scaleup is a Region__c value (1 of 3). Never exists in Cluster__c."
    },
    {
      "id": "region_domestic",
      "terms": ["domestic", "domestic enterprise", "dom", "india domestic"],
      "correctField": "Region__c",
      "correctValue": "Domestic Enterprise",
      "forbiddenFields": ["Cluster__c", "Account_Cluster__c"],
      "reason": "Domestic Enterprise is a Region__c value. Never exists in Cluster__c."
    },
    {
      "id": "region_international",
      "terms": ["international", "intl", "int'l", "international region"],
      "correctField": "Region__c",
      "correctValue": "International",
      "forbiddenFields": ["Cluster__c", "Account_Cluster__c"],
      "reason": "International is a Region__c value. Never exists in Cluster__c."
    },
    {
      "id": "cluster_apac",
      "terms": ["apac", "asia pacific", "asia-pacific"],
      "correctField": "Cluster__c",
      "correctValue": "APAC",
      "forbiddenFields": ["Region__c", "Account_Region__c"],
      "reason": "APAC is a Cluster__c value. Never exists in Region__c."
    },
    {
      "id": "cluster_ksa",
      "terms": ["ksa", "saudi", "saudi arabia"],
      "correctField": "Cluster__c",
      "correctValue": "KSA",
      "forbiddenFields": ["Region__c", "Account_Region__c"],
      "reason": "KSA is a Cluster__c value. Never exists in Region__c."
    },
    {
      "id": "cluster_uae",
      "terms": ["uae", "emirates", "dubai"],
      "correctField": "Cluster__c",
      "correctValue": "UAE",
      "forbiddenFields": ["Region__c", "Account_Region__c"],
      "reason": "UAE is a Cluster__c value. Never exists in Region__c."
    },
    {
      "id": "cluster_mena",
      "terms": ["mena", "middle east", "me"],
      "correctField": "Cluster__c",
      "correctValue": ["UAE", "KSA"],
      "forbiddenFields": ["Region__c", "Account_Region__c"],
      "reason": "MENA maps to Cluster__c IN ('UAE','KSA'). No single MENA value exists."
    },
    {
      "id": "cluster_bfsi",
      "terms": ["bfsi", "banking", "banking and insurance", "financial services"],
      "correctField": "Cluster__c",
      "correctValue": "Banking and Insurance",
      "forbiddenFields": ["Region__c", "Account_Region__c"],
      "reason": "BFSI is a Cluster__c value. Never exists in Region__c."
    },
    {
      "id": "cluster_sme",
      "terms": ["sme", "sme funded"],
      "correctField": "Cluster__c",
      "correctValue": "SME Funded",
      "forbiddenFields": ["Region__c", "Account_Region__c"],
      "reason": "SME Funded is a Cluster__c value. Never exists in Region__c."
    },
    {
      "id": "cluster_retail",
      "terms": ["retail"],
      "correctField": "Cluster__c",
      "correctValue": "Retail",
      "forbiddenFields": ["Region__c", "Account_Region__c"],
      "reason": "Retail is a Cluster__c value. Never exists in Region__c."
    },
    {
      "id": "cluster_technology",
      "terms": ["technology", "tech"],
      "correctField": "Cluster__c",
      "correctValue": "Technology",
      "forbiddenFields": ["Region__c", "Account_Region__c"],
      "reason": "Technology is a Cluster__c value. Never exists in Region__c."
    },
    {
      "id": "cluster_africa",
      "terms": ["africa"],
      "correctField": "Cluster__c",
      "correctValue": "Africa",
      "forbiddenFields": ["Region__c", "Account_Region__c"],
      "reason": "Africa is a Cluster__c value. Never exists in Region__c."
    }
  ]
}
