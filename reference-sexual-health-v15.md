# Reference: Sexual & Urinary Health Check V15 questionnaire

<!-- guide-header:start -->
> **Guide set `2026-11-16.b9b79a`.** Every file in this guide carries this same line.
>
> **Related files you need open with this one:** `README.md` (shared conventions), `assessments.md`
>
> **AI agents, before building anything from this file:** check that you have each related
> file and that its guide-set line reads exactly `2026-11-16.b9b79a`. If a file is missing or its line
> differs, stop and ask the developer for the current copy, naming the files you need (or
> fetch them: `GET /api/mobile-guide/<filename>/`, README "Fetching this guide itself, over
> HTTP"). Never fill a gap from memory or an older copy. Anything the app already shows that
> this guide doesn't describe is out of date: the app must match the website and WhatsApp.
<!-- guide-header:end -->

> Generated from the web app's reference code by `scripts/export-mobile-reference.mjs`. Don't edit by hand.

The question bank and the flow rules the app holds for `sti-uti` and `sti-uti-followup` (see `assessments.md`, "Sexual & Urinary Health Check V15"). Port the wording, order and question conditions as they are.

The code is TypeScript. Treat it as the specification: port it to Dart with the same ids,
wording, order and conditions. The first file is the question bank; the second holds the
rules and imports from the first.

## sexual-health-v15-bank.ts

Source fingerprint: `7e08e0964dfb`

```ts
// The Sexual & Urinary Health question bank, generated from mwh_su_v15.html.
// Wording and answer options are locked by the V15 specification: change them
// only when a new source version is supplied.

export type BankQuestion = { id: string; label: string; opts: string[]; multi: boolean };
export type BankSection = { title: string; questions: BankQuestion[] };

export const COMMON_SYMPTOMS: [string, string][] = [
  [
    "retention",
    "Unable to pass urine despite trying"
  ],
  [
    "weak",
    "Severe weakness, faintness or confusion"
  ],
  [
    "blood",
    "Blood in urine"
  ],
  [
    "flank",
    "Pain in the side or back below the ribs"
  ],
  [
    "systemic",
    "Fever, chills, nausea or vomiting"
  ],
  [
    "burn",
    "Burning or pain when passing urine"
  ],
  [
    "freq_urg",
    "Passing urine more frequently or urgently than usual"
  ],
  [
    "hesitancy",
    "Difficulty starting urination or emptying the bladder"
  ],
  [
    "cloudy",
    "Cloudy or unusually strong-smelling urine"
  ],
  [
    "pelvic",
    "Lower abdominal or pelvic pain or pressure"
  ],
  [
    "rectal",
    "Pain, itching, discharge or bleeding around the anus or rectum"
  ]
];

export const FEMALE_SYMPTOMS: [string, string][] = [
  [
    "vdischarge",
    "Unusual discharge from the vagina"
  ],
  [
    "vulva_irrit",
    "Itching, burning, soreness, redness or swelling around the vulva or vaginal opening"
  ],
  [
    "genital_lesions",
    "Sores, blisters, ulcers, lumps or wart-like growths around the genitals"
  ],
  [
    "sexpain",
    "Pain or discomfort during sexual intercourse"
  ],
  [
    "vbleed",
    "Bleeding after sex or between periods"
  ],
  [
    "vlump",
    "Painful swelling or lump near the vaginal opening"
  ]
];

export const MALE_SYMPTOMS: [string, string][] = [
  [
    "pdischarge",
    "Unusual discharge from the penis"
  ],
  [
    "penile_irrit",
    "Itching, redness, rash or irritation of the penis or foreskin"
  ],
  [
    "genital_lesions",
    "Sores, blisters, ulcers, lumps or wart-like growths on the penis or around the genitals"
  ],
  [
    "testpain",
    "Pain or swelling of the testicles or scrotum"
  ],
  [
    "sexual_pain",
    "Pain during erection or ejaculation"
  ],
  [
    "sexual_function",
    "Difficulty getting or maintaining an erection, or reduced sexual desire"
  ]
];

export const SYMPTOM_ANSWER_KEYS: Record<string, string[]> = {
  "systemic": [
    "systemicDetail",
    "fluidkeep",
    "systemicduration"
  ],
  "flank": [
    "flankside",
    "flankseverity"
  ],
  "burn": [
    "burnwhere",
    "burntiming"
  ],
  "freq_urg": [
    "urinarypattern",
    "urinarynight"
  ],
  "hesitancy": [
    "emptying"
  ],
  "cloudy": [
    "urinechange"
  ],
  "pelvic": [
    "pelvicseverity",
    "pelvicplace",
    "pelviconset",
    "pelvicsudden"
  ],
  "rectal": [
    "rectaltype",
    "rectalduration"
  ],
  "vdischarge": [
    "vcolour",
    "vtexture",
    "vodour"
  ],
  "vulva_irrit": [
    "vulvatype",
    "externalsting"
  ],
  "genital_lesions": [
    "lesiontype",
    "lesionpain",
    "lesiontime",
    "lesionrepeat"
  ],
  "sexpain": [
    "sexpainkind"
  ],
  "vbleed": [
    "bleedtype",
    "bleedheavy"
  ],
  "vlump": [
    "lumpduration"
  ],
  "pdischarge": [
    "pcolour",
    "pconsistency"
  ],
  "penile_irrit": [
    "peniletype"
  ],
  "testpain": [
    "testpainstart",
    "testside",
    "testduration"
  ],
  "sexual_pain": [
    "sexualpainkind"
  ],
  "sexual_function": [
    "sexualfunctionkind",
    "erectionduration",
    "erectionchange"
  ]
};

export const DETAIL_SECTIONS: BankSection[] = [
  {
    "title": "Urinary symptoms",
    "questions": [
      {
        "id": "burnwhere",
        "label": "Where do you feel the burning when passing urine?",
        "opts": [
          "Inside the urinary passage",
          "On the external genital skin",
          "Both",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "burntiming",
        "label": "When does the burning occur?",
        "opts": [
          "When I start passing urine",
          "Throughout urination",
          "When urine touches the skin",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "urinarypattern",
        "label": "What change have you noticed?",
        "opts": [
          "Passing urine more often",
          "Sudden urgency to urinate",
          "Passing small amounts frequently"
        ],
        "multi": true
      },
      {
        "id": "urinarynight",
        "label": "Are you also waking more often at night to pass urine?",
        "opts": [
          "Yes",
          "No",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "emptying",
        "label": "What difficulty do you experience?",
        "opts": [
          "Difficulty starting urine",
          "Weak urine stream",
          "Feeling the bladder is not empty"
        ],
        "multi": true
      },
      {
        "id": "urinechange",
        "label": "What change did you notice in your urine?",
        "opts": [
          "Cloudy urine",
          "Unusually strong smell"
        ],
        "multi": true
      }
    ]
  },
  {
    "title": "Abdominal, back and general symptoms",
    "questions": [
      {
        "id": "pelvicplace",
        "label": "Where is your lower abdominal or pelvic pain?",
        "opts": [
          "Just above the pubic bone / bladder area",
          "Elsewhere in the lower abdomen or pelvis",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "pelviconset",
        "label": "How did the abdominal or pelvic pain start?",
        "opts": [
          "Suddenly",
          "Gradually",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "flankside",
        "label": "Where is the side or back pain?",
        "opts": [
          "Left side",
          "Right side",
          "Both sides",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "flankseverity",
        "label": "How severe is the side or back pain?",
        "opts": [
          "Mild",
          "Moderate",
          "Severe",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "systemicduration",
        "label": "How long have you had the fever, chills, nausea or vomiting?",
        "opts": [
          "Less than a day",
          "1–3 days",
          "More than 3 days",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "fluidkeep",
        "label": "Are you able to keep drinks or fluids down?",
        "opts": [
          "Yes",
          "No",
          "Not sure"
        ],
        "multi": false
      }
    ]
  },
  {
    "title": "Genital sores, blisters or growths",
    "questions": [
      {
        "id": "lesiontype",
        "label": "Which best describes the change around your genitals?",
        "opts": [
          "Sore or ulcer",
          "Blister",
          "Wart-like growth",
          "Other lump",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "lesionpain",
        "label": "Is the sore, blister or growth painful?",
        "opts": [
          "Painful",
          "Painless",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "lesiontime",
        "label": "When did it first appear?",
        "opts": [
          "Within 7 days",
          "1–4 weeks ago",
          "More than 4 weeks ago",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "lesionrepeat",
        "label": "Have similar changes appeared before?",
        "opts": [
          "Yes",
          "No",
          "Not sure"
        ],
        "multi": false
      }
    ]
  },
  {
    "title": "Vaginal discharge",
    "questions": [
      {
        "id": "vcolour",
        "label": "What colour is the unusual vaginal discharge?",
        "opts": [
          "White",
          "Yellow",
          "Green",
          "Grey",
          "Clear or transparent",
          "Brown or blood-stained",
          "Other / Not sure"
        ],
        "multi": false
      },
      {
        "id": "vtexture",
        "label": "How would you describe its texture?",
        "opts": [
          "Thick or clumpy",
          "Thin or watery",
          "Frothy or bubbly",
          "Other / Not sure"
        ],
        "multi": false
      },
      {
        "id": "vodour",
        "label": "Does it have a strong or unpleasant smell?",
        "opts": [
          "Yes",
          "No",
          "Not sure"
        ],
        "multi": false
      }
    ]
  },
  {
    "title": "Vulval symptoms and genital irritation",
    "questions": [
      {
        "id": "vulvatype",
        "label": "Which vulval symptoms are you experiencing?",
        "opts": [
          "Itching",
          "Burning or soreness",
          "Redness",
          "Swelling"
        ],
        "multi": true
      },
      {
        "id": "externalsting",
        "label": "Does urine sting when it touches irritated skin around the vaginal opening?",
        "opts": [
          "Yes",
          "No",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "prevyeast",
        "label": "Have you previously been diagnosed with or treated for vaginal thrush (a yeast infection)?",
        "opts": [
          "Yes",
          "No",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "peniletype",
        "label": "Which penile or foreskin symptoms do you have?",
        "opts": [
          "Itching",
          "Redness or rash",
          "Irritation of the penile head",
          "Foreskin swelling or pain"
        ],
        "multi": true
      }
    ]
  },
  {
    "title": "Penile discharge",
    "questions": [
      {
        "id": "pcolour",
        "label": "What colour is the discharge from the penis?",
        "opts": [
          "Clear or white",
          "Yellow",
          "Green",
          "Other / Not sure"
        ],
        "multi": false
      },
      {
        "id": "pconsistency",
        "label": "How would you describe the discharge?",
        "opts": [
          "Thin or watery",
          "Thick or pus-like",
          "Not sure"
        ],
        "multi": false
      }
    ]
  },
  {
    "title": "Pain or bleeding related to sex",
    "questions": [
      {
        "id": "sexpainkind",
        "label": "Where is the pain during intercourse?",
        "opts": [
          "At or around the vaginal opening",
          "Deep inside the pelvis",
          "Both"
        ],
        "multi": false
      },
      {
        "id": "bleedtype",
        "label": "When does the unexpected bleeding occur?",
        "opts": [
          "After sex",
          "Between periods",
          "Both"
        ],
        "multi": false
      },
      {
        "id": "bleedheavy",
        "label": "How much bleeding are you experiencing?",
        "opts": [
          "Light spotting",
          "Moderate bleeding",
          "Heavy bleeding now",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "lumpduration",
        "label": "When did the painful swelling near the vaginal opening begin?",
        "opts": [
          "Within 24 hours",
          "1–7 days ago",
          "More than 7 days ago",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "sexualpainkind",
        "label": "When does the pain occur?",
        "opts": [
          "During erection",
          "During ejaculation",
          "Both",
          "Not sure"
        ],
        "multi": false
      }
    ]
  },
  {
    "title": "Testicular or scrotal symptoms",
    "questions": [
      {
        "id": "testside",
        "label": "Which side is affected?",
        "opts": [
          "Left",
          "Right",
          "Both",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "testduration",
        "label": "When did it begin?",
        "opts": [
          "Within the last few hours",
          "1–3 days ago",
          "More than 3 days ago",
          "Not sure"
        ],
        "multi": false
      }
    ]
  },
  {
    "title": "Sexual-function concerns",
    "questions": [
      {
        "id": "sexualfunctionkind",
        "label": "Which change have you noticed?",
        "opts": [
          "Difficulty getting or keeping an erection",
          "Reduced sexual desire",
          "Both",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "erectionduration",
        "label": "How long has this concern been present?",
        "opts": [
          "Less than 1 week",
          "1–4 weeks",
          "More than 4 weeks",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "erectionchange",
        "label": "Did the concern begin suddenly?",
        "opts": [
          "Yes",
          "No",
          "Not sure"
        ],
        "multi": false
      }
    ]
  },
  {
    "title": "Rectal symptoms",
    "questions": [
      {
        "id": "rectaltype",
        "label": "What symptoms do you have around the anus or rectum?",
        "opts": [
          "Pain",
          "Itching",
          "Discharge",
          "Bleeding"
        ],
        "multi": true
      },
      {
        "id": "rectalduration",
        "label": "How long have these symptoms been present?",
        "opts": [
          "Less than 7 days",
          "1–4 weeks",
          "More than 4 weeks",
          "Not sure"
        ],
        "multi": false
      }
    ]
  }
];

export const SEXUAL_SECTIONS: BankSection[] = [
  {
    "title": "Time-sensitive HIV exposure",
    "questions": [
      {
        "id": "exposure",
        "label": "In the past 72 hours, are you concerned about a possible HIV exposure?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      }
    ]
  },
  {
    "title": "Recent sexual contact",
    "questions": [
      {
        "id": "sex6",
        "label": "Have you had any sexual contact in the last 6 months?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      },
      {
        "id": "practices",
        "label": "Which types of sexual contact have you had?",
        "opts": [
          "Genital contact",
          "Oral contact",
          "Anal contact"
        ],
        "multi": true
      },
      {
        "id": "newpartner",
        "label": "Have you had a new sexual partner in the last 6 months?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      }
    ]
  },
  {
    "title": "Protection and partner concerns",
    "questions": [
      {
        "id": "protection",
        "label": "When you have sexual contact, how often do you use condoms or other barrier protection?",
        "opts": [
          "Always",
          "Sometimes",
          "Never",
          "Not applicable"
        ],
        "multi": false
      },
      {
        "id": "partner",
        "label": "Has a sexual partner told you that they have an STI or symptoms that might be related to one?",
        "opts": [
          "Yes",
          "No",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "onset",
        "label": "Did your current symptoms begin after sexual contact?",
        "opts": [
          "Yes",
          "No",
          "Not sure"
        ],
        "multi": false
      }
    ]
  },
  {
    "title": "Your sexual health history",
    "questions": [
      {
        "id": "prevsti",
        "label": "Have you previously been diagnosed with or treated for an STI?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      },
      {
        "id": "prevstiwhen",
        "label": "When was your most recent STI diagnosis or treatment?",
        "opts": [
          "Within the last 3 months",
          "Within the last year",
          "More than 1 year ago",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "hiv",
        "label": "Do you know your current HIV status?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      }
    ]
  },
  {
    "title": "Relevant site-specific exposure",
    "questions": [
      {
        "id": "rectalsex",
        "label": "During the past 6 months, have you had anal sex in which a partner penetrated your anus?",
        "opts": [
          "Yes",
          "No",
          "Not sure"
        ],
        "multi": false
      }
    ]
  }
];

export const URINARY_SECTIONS: BankSection[] = [
  {
    "title": "Your current symptoms",
    "questions": [
      {
        "id": "duration",
        "label": "How long have your symptoms been present?",
        "opts": [
          "Less than 24 hours",
          "1–3 days",
          "4–7 days",
          "More than 7 days"
        ],
        "multi": false
      },
      {
        "id": "worse",
        "label": "How have your symptoms changed?",
        "opts": [
          "Getting worse",
          "About the same",
          "Improving"
        ],
        "multi": false
      },
      {
        "id": "perineal_pain",
        "label": "Do you have pain or discomfort between your scrotum and anus?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      }
    ]
  },
  {
    "title": "Previous urinary infections",
    "questions": [
      {
        "id": "prevuti",
        "label": "Have you previously been diagnosed with a UTI by a healthcare professional?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      },
      {
        "id": "uti_recur6",
        "label": "Have you had two or more diagnosed UTIs within any 6-month period?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      },
      {
        "id": "uti_recur12",
        "label": "Have you had three or more diagnosed UTIs within any 12-month period?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      },
      {
        "id": "uti_test",
        "label": "Have you previously had a urine test to investigate these repeated urinary symptoms?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      },
      {
        "id": "uti_test_result",
        "label": "What were you told about the urine test result?",
        "opts": [
          "An infection was found",
          "No infection was found",
          "Another result was mentioned",
          "I was not told / do not remember"
        ],
        "multi": false
      }
    ]
  },
  {
    "title": "Recent antibiotic treatment",
    "questions": [
      {
        "id": "antibiotics",
        "label": "Have you taken antibiotics within the last 4 weeks?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      },
      {
        "id": "antibiotics_current",
        "label": "Are you still taking these antibiotics?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      },
      {
        "id": "antibiotics_response",
        "label": "Did your urinary or genital symptoms improve while taking the antibiotics?",
        "opts": [
          "Yes, improved",
          "No improvement",
          "Improved then returned",
          "Antibiotics were for another condition"
        ],
        "multi": false
      }
    ]
  },
  {
    "title": "Other health conditions and urinary care",
    "questions": [
      {
        "id": "urinary_history_gate",
        "label": "Do you have a health condition or recent medical care that may affect your urinary health?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      }
    ]
  },
  {
    "title": "Catheters, procedures and urinary conditions",
    "questions": [
      {
        "id": "catheter",
        "label": "Do you currently have a urinary catheter?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      },
      {
        "id": "urinary_procedure",
        "label": "Have you had a urinary tract procedure or instrumentation within the last 3 months?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      },
      {
        "id": "kidney",
        "label": "Have you been diagnosed with kidney disease?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      },
      {
        "id": "obstruction",
        "label": "Have you been diagnosed with a blockage or obstruction affecting urine flow?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      },
      {
        "id": "urinary_other",
        "label": "Have you been diagnosed with another urinary tract condition, such as urinary stones?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      }
    ]
  },
  {
    "title": "Other medical history",
    "questions": [
      {
        "id": "diabetes",
        "label": "Have you previously been diagnosed with diabetes?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      },
      {
        "id": "prostate",
        "label": "Have you previously been diagnosed with a prostate problem?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      }
    ]
  }
];

export const FOLLOWUP_SECTIONS: BankSection[] = [
  {
    "title": "How you are feeling now",
    "questions": [
      {
        "id": "fu_status",
        "label": "Compared with your initial assessment, how are your symptoms now?",
        "opts": [
          "Completely resolved",
          "Improved, but still present",
          "About the same",
          "Getting worse",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "fu_new",
        "label": "Have you developed any new symptoms since the initial assessment?",
        "opts": [
          "Yes",
          "No",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "fu_danger",
        "label": "Do the new symptoms include severe pain, fever with back or side pain, repeated vomiting, inability to pass urine, sudden testicular pain, fainting or confusion?",
        "opts": [
          "Yes",
          "No",
          "Not sure"
        ],
        "multi": false
      }
    ]
  },
  {
    "title": "Consultation and treatment",
    "questions": [
      {
        "id": "fu_seen",
        "label": "Have you been assessed by a healthcare professional for this concern?",
        "opts": [
          "Yes",
          "No",
          "Appointment planned"
        ],
        "multi": false
      },
      {
        "id": "fu_rx",
        "label": "Were you prescribed treatment for this concern?",
        "opts": [
          "Yes",
          "No",
          "Not sure"
        ],
        "multi": false
      },
      {
        "id": "fu_complete",
        "label": "What is the status of your prescribed treatment?",
        "opts": [
          "Completed as instructed",
          "Still taking it as instructed",
          "Stopped early or missed doses",
          "Not sure"
        ],
        "multi": false
      }
    ]
  },
  {
    "title": "Partner care and ongoing support",
    "questions": [
      {
        "id": "fu_partner",
        "label": "Did your clinician advise sexual partner notification, testing or treatment?",
        "opts": [
          "Yes",
          "No",
          "Not discussed"
        ],
        "multi": false
      },
      {
        "id": "fu_partner_done",
        "label": "Were you able to notify your partner(s) or request confidential support?",
        "opts": [
          "Yes",
          "No"
        ],
        "multi": false
      },
      {
        "id": "fu_support",
        "label": "Would you like a further clinical review for any remaining concerns?",
        "opts": [
          "Yes",
          "No",
          "Not sure"
        ],
        "multi": false
      }
    ]
  }
];
```

## sexual-health-v15.ts

Source fingerprint: `e9c9f5e17698`

```ts
// Sexual & Urinary Health Check V15: the source file's safetyGate and question display
// conditions, so safety screens react to each tap. The server re-checks them on every
// action and owns classify() and clinicalPriority() (apps.assessments.engine.sexual_health_v15,
// tested against the source file). Change behaviour only with a new source version.

import {
  COMMON_SYMPTOMS,
  DETAIL_SECTIONS,
  FEMALE_SYMPTOMS,
  FOLLOWUP_SECTIONS,
  MALE_SYMPTOMS,
  SEXUAL_SECTIONS,
  SYMPTOM_ANSWER_KEYS,
  URINARY_SECTIONS,
  type BankQuestion,
  type BankSection,
} from "./sexual-health-v15-bank";

export type Sex = "female" | "male";
export type AnswerValue = string | string[];
export type Answers = Record<string, AnswerValue>;

export type FlowFacts = {
  sex: Sex;
  sym: string[]; // In tap order, which is clinically meaningful.
  answers: Answers;
  pepAcknowledged: boolean;
  profileDiabetes: string | null;
  // The check-in's partner questions depend on the initial health check's routing.
  initialCareId?: string;
};

export type SafetyGate = {
  kind: "emergency" | "pep" | "today";
  title: string;
  reason: string;
  advice: string;
  pathway?: "pyelo";
};

export type FlowQuestion = BankQuestion & { groupTitle: string; symptomId?: string };

export const symptomList = (sex: Sex) => [...COMMON_SYMPTOMS, ...(sex === "female" ? FEMALE_SYMPTOMS : MALE_SYMPTOMS)];
export const has = (f: FlowFacts, id: string) => f.sym.includes(id);
export const ans = (f: FlowFacts, id: string): AnswerValue =>
  id === "diabetes" && f.profileDiabetes !== null ? f.profileDiabetes : (f.answers[id] ?? "");
export const hasSymptoms = (f: FlowFacts) => f.sym.length > 0 && !has(f, "none");
const includes = (f: FlowFacts, id: string, value: string) => {
  const v = ans(f, id);
  return Array.isArray(v) && v.includes(value);
};

export function safetyGate(f: FlowFacts): SafetyGate | null {
  const lowerSymptoms = has(f, "burn") || has(f, "freq_urg") || has(f, "hesitancy") || has(f, "pelvic");
  const fever = includes(f, "systemicDetail", "Fever");
  const chills = includes(f, "systemicDetail", "Chills");
  const vomit = includes(f, "systemicDetail", "Vomiting");
  const infectionContext = lowerSymptoms || has(f, "flank") || has(f, "systemic");
  const a = (id: string) => ans(f, id);
  if (has(f, "retention")) return { kind: "emergency", title: "Unable to pass urine", reason: "You reported being unable to pass urine despite trying.", advice: "Seek emergency medical assessment now." };
  if (has(f, "weak")) return { kind: "emergency", title: "Severe weakness, faintness or confusion", reason: "These symptoms can occur with serious illness.", advice: "Seek emergency medical care immediately." };
  if (has(f, "testpain") && a("testpainstart") === "Yes") return { kind: "emergency", title: "Sudden or severe testicular pain", reason: "Testicular torsion is one of the possible causes and requires urgent exclusion.", advice: "Go to an emergency department immediately. Do not wait to complete this assessment." };
  if (has(f, "pelvic") && a("pelvicseverity") === "Severe") return { kind: "emergency", title: "Severe pelvic or abdominal pain", reason: "Severe pelvic or lower abdominal pain requires urgent examination.", advice: "Seek emergency medical assessment now." };
  if (has(f, "vbleed") && a("bleedheavy") === "Heavy bleeding now") return { kind: "emergency", title: "Heavy vaginal bleeding", reason: "Heavy bleeding needs urgent examination.", advice: "Seek emergency medical care now." };
  if (a("exposure") === "Yes" && !f.pepAcknowledged) return { kind: "pep", title: "Possible HIV exposure within 72 hours", reason: "You reported concern about possible recent HIV exposure.", advice: "Please visit a healthcare facility of your choice immediately for confidential professional guidance and an assessment of whether HIV post-exposure prophylaxis (PEP) is appropriate. PEP works best when started as soon as possible and must be started within 72 hours when indicated." };
  if (has(f, "flank") && a("flankseverity") === "Severe") return { kind: "today", title: "Severe flank or side pain", reason: "Severe pain below the ribs may be caused by kidney stones, obstruction, infection or another serious condition.", advice: "Visit a healthcare facility immediately for an in-person assessment. Seek emergency care if pain is unbearable or accompanied by severe illness." };
  if (has(f, "flank") && (fever || chills || vomit)) return { kind: "today", pathway: "pyelo", title: "Possible kidney infection (pyelonephritis)", reason: "Flank pain with fever, chills or vomiting can indicate an upper urinary infection or another urgent condition.", advice: "Visit a healthcare facility today for clinical assessment. Seek emergency care if very unwell, fainting, confused or unable to keep fluids down." };
  if (fever && lowerSymptoms) return { kind: "today", title: "Fever with urinary or pelvic symptoms", reason: "A fever with urinary or pelvic symptoms may indicate a systemic infection, prostatitis, pelvic inflammatory disease or another condition.", advice: "Visit a healthcare facility today for a clinical assessment. Seek emergency care if you become severely unwell." };
  if (f.sex === "male" && a("perineal_pain") === "Yes" && (has(f, "burn") || has(f, "pelvic") || fever)) return { kind: "today", title: "Possible acute prostate or urinary concern", reason: "Perineal pain alongside urinary or systemic symptoms can have causes that require prompt examination.", advice: "Visit a healthcare facility today." };
  if (f.sex === "female" && has(f, "pelvic") && (fever || a("pelvicsudden") === "Yes")) return { kind: "today", title: "Pelvic pain requiring prompt evaluation", reason: "Pelvic pain with fever or sudden onset requires clinical review for pelvic inflammatory disease and other causes.", advice: "Visit a healthcare facility today. Seek emergency assessment if the pain is severe, accompanied by fainting or rapidly worsening." };
  if (fever && vomit) return { kind: "today", title: "Fever and vomiting", reason: "These symptoms can indicate an illness needing urgent evaluation even without urinary symptoms.", advice: "Visit a healthcare facility today; seek emergency care if unable to keep fluids down or severely unwell." };
  if (vomit && a("fluidkeep") === "No") return { kind: "today", title: "Unable to keep fluids down", reason: "Repeated vomiting with inability to keep fluids down may cause dehydration or indicate a serious condition.", advice: "Visit a healthcare facility promptly today; use emergency services if very weak or faint." };
  if (has(f, "blood")) return { kind: "today", title: "Visible blood in urine", reason: "Visible blood in urine requires clinical assessment even when there is no pain.", advice: "Visit a healthcare facility promptly, preferably today. Seek emergency care for clots, inability to urinate or severe pain." };
  if (has(f, "testpain")) return { kind: "today", title: "Testicular or scrotal symptoms", reason: "Testicular pain or swelling requires clinical examination, even when the onset is unclear.", advice: "Seek in-person assessment today; seek emergency care for sudden or severe pain." };
  if ((a("obstruction") === "Yes" || a("catheter") === "Yes" || a("urinary_procedure") === "Yes" || a("kidney") === "Yes") && infectionContext) return { kind: "today", title: "Urinary symptoms with additional risk factors", reason: "A urinary catheter, recent instrumentation, kidney disease or diagnosed obstruction may change the urgency of evaluating urinary symptoms.", advice: "Contact a healthcare facility for an in-person assessment today. Seek emergency care for fever with severe illness, obstruction or worsening pain." };
  if (a("worse") === "Getting worse" && hasSymptoms(f)) return { kind: "today", title: "Symptoms are worsening", reason: "You report that the current symptoms are getting worse.", advice: "Arrange a prompt in-person clinical assessment; seek urgent care now if danger signs develop." };
  return null;
}

const female = (f: FlowFacts) => f.sex === "female";
const male = (f: FlowFacts) => f.sex === "male";
const partnerPathway = (f: FlowFacts) => f.initialCareId === "sti" || f.initialCareId === "combined";
const oralOnly = (f: FlowFacts) => {
  const p = ans(f, "practices");
  return Array.isArray(p) && p.length === 1 && p[0] === "Oral contact";
};

const CONDITIONS: Record<string, (f: FlowFacts) => boolean> = {
  burnwhere: (f) => has(f, "burn"),
  burntiming: (f) => has(f, "burn"),
  urinarypattern: (f) => has(f, "freq_urg"),
  urinarynight: (f) => has(f, "freq_urg"),
  emptying: (f) => has(f, "hesitancy"),
  urinechange: (f) => has(f, "cloudy"),
  pelvicplace: (f) => has(f, "pelvic"),
  pelviconset: (f) => has(f, "pelvic") && male(f),
  flankside: (f) => has(f, "flank"),
  flankseverity: (f) => has(f, "flank") && !ans(f, "flankseverity"),
  systemicduration: (f) => has(f, "systemic"),
  fluidkeep: (f) => has(f, "systemic") && includes(f, "systemicDetail", "Vomiting"),
  lesiontype: (f) => has(f, "genital_lesions"),
  lesionpain: (f) => has(f, "genital_lesions"),
  lesiontime: (f) => has(f, "genital_lesions"),
  lesionrepeat: (f) => has(f, "genital_lesions"),
  vcolour: (f) => female(f) && has(f, "vdischarge"),
  vtexture: (f) => female(f) && has(f, "vdischarge"),
  vodour: (f) => female(f) && has(f, "vdischarge"),
  vulvatype: (f) => female(f) && has(f, "vulva_irrit"),
  externalsting: (f) => female(f) && has(f, "vulva_irrit"),
  prevyeast: (f) => female(f) && (has(f, "vulva_irrit") || has(f, "vdischarge")),
  peniletype: (f) => male(f) && has(f, "penile_irrit"),
  pcolour: (f) => male(f) && has(f, "pdischarge"),
  pconsistency: (f) => male(f) && has(f, "pdischarge"),
  sexpainkind: (f) => female(f) && has(f, "sexpain"),
  bleedtype: (f) => female(f) && has(f, "vbleed"),
  bleedheavy: (f) => female(f) && has(f, "vbleed"),
  lumpduration: (f) => female(f) && has(f, "vlump"),
  sexualpainkind: (f) => male(f) && has(f, "sexual_pain"),
  testside: (f) => male(f) && has(f, "testpain"),
  testduration: (f) => male(f) && has(f, "testpain"),
  sexualfunctionkind: (f) => male(f) && has(f, "sexual_function"),
  erectionduration: (f) => male(f) && has(f, "sexual_function"),
  erectionchange: (f) => male(f) && has(f, "sexual_function"),
  rectaltype: (f) => has(f, "rectal"),
  rectalduration: (f) => has(f, "rectal"),
  exposure: (f) => !ans(f, "exposure"),
  practices: (f) => ans(f, "sex6") === "Yes",
  newpartner: (f) => ans(f, "sex6") === "Yes",
  protection: (f) => ans(f, "sex6") === "Yes" && !oralOnly(f),
  onset: (f) => ans(f, "sex6") === "Yes" && hasSymptoms(f),
  prevstiwhen: (f) => ans(f, "prevsti") === "Yes",
  rectalsex: (f) => ans(f, "sex6") === "Yes" && (has(f, "rectal") || includes(f, "practices", "Anal contact")),
  duration: hasSymptoms,
  worse: hasSymptoms,
  perineal_pain: (f) => male(f) && (has(f, "hesitancy") || has(f, "pelvic") || has(f, "burn")),
  uti_recur6: (f) => ans(f, "prevuti") === "Yes",
  uti_recur12: (f) => ans(f, "prevuti") === "Yes",
  uti_test: (f) => ans(f, "prevuti") === "Yes" && (ans(f, "uti_recur6") === "Yes" || ans(f, "uti_recur12") === "Yes"),
  uti_test_result: (f) => ans(f, "uti_test") === "Yes",
  antibiotics_current: (f) => ans(f, "antibiotics") === "Yes",
  antibiotics_response: (f) => ans(f, "antibiotics") === "Yes" && hasSymptoms(f),
  catheter: (f) => ans(f, "urinary_history_gate") === "Yes",
  urinary_procedure: (f) => ans(f, "urinary_history_gate") === "Yes",
  kidney: (f) => ans(f, "urinary_history_gate") === "Yes",
  obstruction: (f) => ans(f, "urinary_history_gate") === "Yes",
  urinary_other: (f) => ans(f, "urinary_history_gate") === "Yes",
  diabetes: (f) => ans(f, "urinary_history_gate") === "Yes" && f.profileDiabetes === null,
  prostate: (f) => ans(f, "urinary_history_gate") === "Yes" && male(f) && has(f, "hesitancy"),
  fu_danger: (f) => ans(f, "fu_new") === "Yes",
  fu_rx: (f) => ans(f, "fu_seen") === "Yes",
  fu_complete: (f) => ans(f, "fu_rx") === "Yes",
  fu_partner: partnerPathway,
  fu_partner_done: (f) => partnerPathway(f) && ans(f, "fu_partner") === "Yes",
};

const shown = (sections: BankSection[], f: FlowFacts): FlowQuestion[] =>
  sections.flatMap((s) =>
    s.questions.filter((q) => CONDITIONS[q.id]?.(f) ?? true).map((q) => ({ ...q, groupTitle: s.title })),
  );

function detailSymptomId(questionId: string, f: FlowFacts): string | null {
  if (questionId === "prevyeast") return has(f, "vdischarge") ? "vdischarge" : "vulva_irrit";
  for (const [id, keys] of Object.entries(SYMPTOM_ANSWER_KEYS)) {
    if (has(f, id) && keys.includes(questionId)) return id;
  }
  return null;
}

// Part 2: every selected symptom's questions together, in the order they were tapped.
export function detailQuestions(f: FlowFacts): FlowQuestion[] {
  const bySymptom = new Map<string, FlowQuestion[]>();
  for (const q of shown(DETAIL_SECTIONS, f)) {
    const id = detailSymptomId(q.id, f);
    if (!id) continue;
    bySymptom.set(id, [...(bySymptom.get(id) ?? []), { ...q, symptomId: id }]);
  }
  return f.sym.filter((id) => id !== "none" && bySymptom.has(id)).flatMap((id) => bySymptom.get(id)!);
}

export const sexualQuestions = (f: FlowFacts) => shown(SEXUAL_SECTIONS, f);
export const urinaryQuestions = (f: FlowFacts) => shown(URINARY_SECTIONS, f);
export const followUpQuestions = (f: FlowFacts) => shown(FOLLOWUP_SECTIONS, f);

export function symptomTitle(f: Pick<FlowFacts, "sex">, id: string): string {
  return symptomList(f.sex).find((p) => p[0] === id)?.[1] ?? "Your selected symptom";
}

export const DETAIL_ANSWER_KEYS = new Set([...Object.values(SYMPTOM_ANSWER_KEYS).flat(), "pelvicsudden", "prevyeast"]);

// The source labels the consultation summary from the questions currently showing, so an
// answer whose question is hidden printed its internal ID (e.g. "systemicDetail"). Every
// answer is labelled from its own question here instead.
const INLINE_LABELS: Record<string, string> = {
  systemicDetail: "Which of these do you have?",
  testpainstart: "Did testicular pain begin suddenly, or is the pain severe?",
  flankseverity: "How severe is this side or back pain?",
  pelvicseverity: "How severe is the pelvic or lower abdominal pain?",
  pelvicsudden: "Sudden or one-sided pelvic pain",
  unwanted: "Confidential medical support requested",
};
const BANK_LABELS: Record<string, string> = Object.fromEntries(
  [...DETAIL_SECTIONS, ...SEXUAL_SECTIONS, ...URINARY_SECTIONS].flatMap((s) => s.questions.map((q) => [q.id, q.label])),
);
export const answerLabel = (key: string) => INLINE_LABELS[key] ?? BANK_LABELS[key] ?? key;
export const SEXUAL_ANSWER_KEYS = new Set([
  "exposure",
  "unwanted",
  ...SEXUAL_SECTIONS.flatMap((s) => s.questions.map((q) => q.id)),
]);

// Clears answers that no longer apply, exactly as the source's answer() does.
export function applyAnswer(answers: Answers, id: string, value: string): Answers {
  const next: Answers = { ...answers, [id]: value };
  const drop = (...keys: string[]) => keys.forEach((k) => delete next[k]);
  if (id === "sex6" && value !== "Yes") drop("practices", "newpartner", "protection", "onset", "rectalsex");
  if (id === "prevsti" && value !== "Yes") drop("prevstiwhen");
  if (id === "prevuti" && value !== "Yes") drop("uti_recur6", "uti_recur12", "uti_test", "uti_test_result");
  if ((id === "uti_recur6" || id === "uti_recur12") && next.uti_recur6 !== "Yes" && next.uti_recur12 !== "Yes") {
    drop("uti_test", "uti_test_result");
  }
  if (id === "uti_test" && value !== "Yes") drop("uti_test_result");
  if (id === "antibiotics" && value !== "Yes") drop("antibiotics_current", "antibiotics_response");
  if (id === "urinary_history_gate" && value !== "Yes") {
    drop("catheter", "urinary_procedure", "kidney", "obstruction", "urinary_other", "diabetes", "prostate");
  }
  return next;
}

// The source's toggleMulti().
export function applyMulti(answers: Answers, id: string, value: string): Answers {
  const current = Array.isArray(answers[id]) ? (answers[id] as string[]) : [];
  const next: Answers = {
    ...answers,
    [id]: current.includes(value) ? current.filter((x) => x !== value) : [...current, value],
  };
  const practices = next[id] as string[];
  if (id === "practices" && practices.length === 1 && practices[0] === "Oral contact") delete next.protection;
  return next;
}

// The source's toggleSym(): keeps tap order, and "none" clears everything else.
export function applySymptom(sym: string[], answers: Answers, id: string): { sym: string[]; answers: Answers } {
  let nextSym = sym;
  let next: Answers = { ...answers };
  if (id === "none") {
    nextSym = ["none"];
    next = Object.fromEntries(
      ["exposure", "unwanted"].filter((k) => answers[k] !== undefined && answers[k] !== "").map((k) => [k, answers[k]]),
    );
  } else {
    nextSym = sym.filter((x) => x !== "none");
    if (nextSym.includes(id)) {
      nextSym = nextSym.filter((x) => x !== id);
      (SYMPTOM_ANSWER_KEYS[id] ?? []).forEach((k) => delete next[k]);
    } else {
      nextSym = [...nextSym, id];
    }
  }
  if (!nextSym.includes("testpain")) delete next.testpainstart;
  return { sym: nextSym, answers: next };
}
```
