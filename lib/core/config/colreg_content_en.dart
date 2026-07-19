// ── COLREG – English content ────────────────────────────────────
// Rule quotations follow the IMO Convention on the International
// Regulations for Preventing Collisions at Sea, 1972 (as amended),
// abridged where marked. Commentary is adapted from Tim Bartlett,
// "COLREGs Explained", RYA/IFP Publishing.
//
// Block types live in colreg_content.dart; this file holds data only.
// Section ids and diagram keys must stay identical to the Slovak file.

import 'colreg_content.dart';

final List<ColregSection> colregChaptersEn = [
  _chapter1,
  _chapter2,
  _chapter3,
  _chapter4,
  _chapter5,
  _chapter6,
  _chapter7,
];

// ── Chapter 1: Who, when, where? ────────────────────────────────

final _chapter1 = ColregSection(
  id: 'ch1',
  title: '1: Who, when, where?',
  blocks: [
    ColregText(
      'The first part of the COLREGs (Part A: General) sets out the basic '
      'definitions and the scope over which the rules apply.',
    ),
  ],
  children: [
    ColregSection(
      id: 'rule1',
      title: 'Rule 1: Application',
      ruleNumber: '1',
      blocks: [
        ColregRuleBox(
          title: 'Rule 1: Application',
          text:
              'a) These Rules shall apply to all vessels upon the high seas '
              'and in all waters connected therewith navigable by seagoing '
              'vessels.\n\n'
              'b) Nothing in these Rules shall interfere with the operation '
              'of special rules made by an appropriate authority for '
              'roadsteads, harbours, rivers, lakes or inland waterways '
              'connected with the high seas and navigable by seagoing '
              'vessels. Such special rules shall conform as closely as '
              'possible to these Rules.\n\n'
              'c) Nothing in these Rules shall interfere with the operation '
              'of any special rules made by the Government of any State with '
              'respect to additional station or signal lights, shapes or '
              'whistle signals for ships of war and vessels proceeding under '
              'convoy, or for fishing vessels engaged in fishing as a fleet.\n\n'
              'd) Traffic separation schemes may be adopted by the '
              'Organization for the purpose of these Rules.\n\n'
              'e) Whenever a Government determines that a vessel of special '
              'construction or purpose cannot comply fully with any of these '
              'Rules with respect to lights, shapes, or sound-signalling '
              'appliances, she shall comply with such other provisions as '
              'her Government has determined to be the closest possible '
              'compliance with these Rules.',
        ),
        ColregText(
          'The first paragraph is straightforward: if you are on any vessel, '
          'on any water connected to the sea, the COLREGs apply to you.',
        ),
        ColregText(
          'The remaining paragraphs let governments and local authorities '
          'make their own regulations for specific local conditions – speed '
          'limits in harbours, dedicated VHF channels, or a rule giving the '
          'local ferry priority over everyone else.',
        ),
        ColregNote(
          'Local regulations should supplement the COLREGs; they should '
          'never contradict them.',
          type: ColregNoteType.info,
        ),
      ],
    ),
    ColregSection(
      id: 'rule2',
      title: 'Rule 2: Responsibility',
      ruleNumber: '2',
      blocks: [
        ColregRuleBox(
          title: 'Rule 2: Responsibility',
          text:
              'a) Nothing in these Rules shall exonerate any vessel, or the '
              'owner, master or crew thereof, from the consequences of any '
              'neglect to comply with these Rules or of the neglect of any '
              'precaution which may be required by the ordinary practice of '
              'seamen, or by the special circumstances of the case.\n\n'
              'b) In construing and complying with these Rules due regard '
              'shall be had to all dangers of navigation and collision and '
              'to any special circumstances, including the limitations of '
              'the vessels involved, which may make a departure from these '
              'Rules necessary to avoid immediate danger.',
        ),
        ColregText(
          'Rule 2 says the regulations do not replace common sense and good '
          'seamanship. If the circumstances of a particular situation would '
          'make following the letter of a rule dangerous, you are not merely '
          'allowed to depart from it – you are required to.',
        ),
        ColregText(
          'Example: the COLREGs grant no special rights to vessels at anchor, '
          'but it would be absurd to hit the side of an anchored vessel and '
          'then blame her for not giving way.',
        ),
        ColregNote(
          'Rule 2 does not, however, license breaking the rules just because '
          'it suits someone or is more convenient. A departure is permissible '
          'only where it is "necessary to avoid immediate danger".',
          type: ColregNoteType.warning,
        ),
      ],
    ),
    ColregSection(
      id: 'rule3',
      title: 'Rule 3: Definitions',
      ruleNumber: '3',
      blocks: [
        ColregRuleBox(
          title: 'Rule 3: Definitions (selected)',
          text:
              'a) "Vessel" – every description of water craft, including '
              'non-displacement craft, WIG craft and seaplanes, used or '
              'capable of being used as a means of transportation on water.\n\n'
              'b) "Power-driven vessel" – any vessel propelled by machinery.\n\n'
              'c) "Sailing vessel" – any vessel under sail provided that '
              'propelling machinery, if fitted, is not being used.\n\n'
              'd) "Vessel engaged in fishing" – any vessel fishing with nets, '
              'lines, trawls or other fishing apparatus which restrict '
              'manoeuvrability, but does not include a vessel fishing with '
              'trolling lines.\n\n'
              'f) "Vessel not under command" – a vessel which through some '
              'exceptional circumstance is unable to manoeuvre as required by '
              'these Rules and is therefore unable to keep out of the way of '
              'another vessel.\n\n'
              'g) "Vessel restricted in her ability to manoeuvre" – a vessel '
              'which from the nature of her work is restricted in her ability '
              'to manoeuvre (laying cable, dredging, replenishment at sea, '
              'towing, etc.).\n\n'
              'k) Vessels shall be deemed to be in sight of one another only '
              'when one can be observed visually from the other.\n\n'
              'l) "Restricted visibility" – any condition in which visibility '
              'is restricted by fog, mist, falling snow, heavy rainstorms, '
              'sandstorms or any other similar causes.',
        ),
        ColregText(
          'Important: a vessel\'s "status" under the COLREGs depends on what '
          'she is actually doing – not on what she is capable of doing.',
        ),
        ColregList([
          'A fishing boat is a "vessel engaged in fishing" only while she is '
              'actually using gear that restricts her manoeuvring. She is not '
              'one while steaming home from the fishing grounds.',
          'A sailing yacht has the rights and duties of a "sailing vessel" '
              'only while actually under sail. Under engine – including while '
              'motorsailing – she is a "power-driven vessel".',
        ]),
        ColregNote(
          'Vessels restricted in their ability to manoeuvre include: laying '
          'navigation marks or cable; dredging and survey work; replenishment '
          'under way; launching or recovering aircraft; mine clearance; and '
          'towing operations that severely restrict manoeuvring.',
          type: ColregNoteType.info,
        ),
      ],
    ),
  ],
);

// ── Chapter 2: Assessing the risk ───────────────────────────────

final _chapter2 = ColregSection(
  id: 'ch2',
  title: '2: Assessing the risk',
  blocks: [
    ColregText(
      'Part B Section I of the COLREGs contains the rules that apply in any '
      'condition of visibility (Rules 4–10).',
    ),
  ],
  children: [
    ColregSection(
      id: 'rule5',
      title: 'Rule 5: Look-out',
      ruleNumber: '5',
      blocks: [
        ColregRuleBox(
          title: 'Rule 5: Look-out',
          text:
              'Every vessel shall at all times maintain a proper look-out by '
              'sight and hearing as well as by all available means '
              'appropriate in the prevailing circumstances and conditions so '
              'as to make a full appraisal of the situation and of the risk '
              'of collision.',
        ),
        ColregText(
          'Without a look-out you cannot hope to avoid something you do not '
          'even know is there. More collisions have been caused by a failure '
          'to keep a proper look-out than by breaches of any other rule.',
        ),
        ColregHeading('Blind spots'),
        ColregDiagram('blind_spots', 'Typical blind spots on a sailing yacht and a motor yacht'),
        ColregText(
          'Most sailing yachts have at least two significant blind spots: '
          'behind the headsail (jib or genoa) on the leeward side, and behind '
          'the coachroof or sprayhood. Most motor yachts steered from a '
          'wheelhouse have a large blind spot astern and smaller ones behind '
          'the window pillars.',
        ),
        ColregList([
          'Do not sit or stand in the same place for more than a few minutes',
          'Before altering course, look carefully astern as well',
          'Put a crew member on the leeward side for a better view forward',
        ]),
        ColregHeading('Using radar, VHF and AIS'),
        ColregText(
          'If radar, VHF or AIS helps you assess the situation better, using '
          'them is compulsory, not optional. In fog it would be the height of '
          'folly not to use radar if you have it.',
        ),
        ColregNote(
          'Night vision takes up to half an hour to develop, but is lost the '
          'instant someone switches on a torch or a cabin light. Use dimmed '
          'red lighting at the chart table.',
          type: ColregNoteType.info,
        ),
      ],
    ),
    ColregSection(
      id: 'rule6',
      title: 'Rule 6: Safe speed',
      ruleNumber: '6',
      blocks: [
        ColregRuleBox(
          title: 'Rule 6: Safe speed',
          text:
              'Every vessel shall at all times proceed at a safe speed so '
              'that she can take proper and effective action to avoid '
              'collision and be stopped within a distance appropriate to the '
              'prevailing circumstances and conditions. Factors to be taken '
              'into account include: the state of visibility; the traffic '
              'density; the manoeuvrability of the vessel, especially '
              'stopping distance and turning ability; at night, the presence '
              'of background light; the state of wind, sea and current; the '
              'draught in relation to the available depth of water; and, '
              'where radar is in use, its characteristics, efficiency and '
              'limitations.',
        ),
        ColregText(
          'Speed alone rarely causes a collision, but it lengthens the '
          'stopping distance, cuts the time available to decide, and '
          'increases the damage if a collision does happen.',
        ),
        ColregNote(
          'Investigators into the collision between the 14-metre yacht '
          'Wahkuna and the 227-metre container ship Nedlloyd Vespucci found '
          'the container ship had been making 25 knots in visibility of only '
          '50 metres. Of 19 other vessels in the area, just one had reduced '
          'speed for the visibility.',
          type: ColregNoteType.story,
        ),
        ColregText(
          'Small craft have one great advantage: high manoeuvrability. '
          'Skippers of sailing yachts should not throw that advantage away '
          'by carrying an over-complicated sail plan at low speed.',
        ),
      ],
    ),
    ColregSection(
      id: 'rule7',
      title: 'Rule 7: Risk of collision',
      ruleNumber: '7',
      blocks: [
        ColregRuleBox(
          title: 'Rule 7: Risk of collision',
          text:
              'a) Every vessel shall use all available means appropriate to '
              'the prevailing circumstances and conditions to determine if '
              'risk of collision exists. If there is any doubt such risk '
              'shall be deemed to exist.\n\n'
              'b) Proper use shall be made of radar equipment if fitted and '
              'operational, including long-range scanning to obtain early '
              'warning of risk of collision.\n\n'
              'c) Assumptions shall not be made on the basis of scanty '
              'information, especially scanty radar information.\n\n'
              'd) Risk of collision shall be deemed to exist if the compass '
              'bearing of an approaching vessel does not appreciably change. '
              'Such risk may sometimes exist even when an appreciable bearing '
              'change is evident, particularly when approaching a very large '
              'vessel or a tow, or when approaching a vessel at close range.',
        ),
        ColregHeading('The constant bearing test'),
        ColregDiagram('bearing_test', 'Lining an approaching vessel up against a stanchion'),
        ColregText(
          'The classic test: line the approaching vessel up with a fixed part '
          'of your own boat, such as a guardrail stanchion. If she is still '
          'in line a few minutes later and you have been holding a steady '
          'course, the compass bearing has not changed – you are heading for '
          'a collision or a very close pass.',
        ),
        ColregNote(
          'Careful: this checks the relative bearing, not the compass '
          'bearing. If you cannot hold a perfectly steady course it can give '
          'you a false sense of security. Watch out especially for very large '
          'vessels and long tows – if the bearing of the stern is drawing aft '
          'while the bearing of the bow draws forward, you will hit her '
          'somewhere in the middle.',
          type: ColregNoteType.warning,
        ),
      ],
    ),
    ColregSection(
      id: 'rule8',
      title: 'Rule 8: Action to avoid collision',
      ruleNumber: '8',
      blocks: [
        ColregRuleBox(
          title: 'Rule 8: Action to avoid collision',
          text:
              'a) Any action to avoid collision shall be taken in accordance '
              'with the Rules of this Part and shall, if the circumstances '
              'admit, be positive, made in ample time and with due regard to '
              'the observance of good seamanship.\n\n'
              'b) Any alteration of course and/or speed shall be large enough '
              'to be readily apparent to another vessel observing visually or '
              'by radar; a succession of small alterations should be avoided.\n\n'
              'c) If there is sufficient sea room, alteration of course alone '
              'may be the most effective action.\n\n'
              'd) Action shall be such as to result in passing at a safe '
              'distance; its effectiveness shall be carefully checked until '
              'the other vessel is finally past and clear.\n\n'
              'e) If necessary, a vessel shall slacken her speed or take all '
              'way off by stopping or reversing her means of propulsion.',
        ),
        ColregText(
          'A "positive" alteration of course means one big enough for the '
          'look-out on the other vessel to notice. Meeting almost end-on at '
          'night, an alteration of about 10° may be enough for the other '
          'vessel to see your red light instead of your green. Seen from the '
          'side, even 30–40° can be hard to spot.',
        ),
        ColregDiagram('positive_action', 'An indistinct alteration compared with a positive one'),
        ColregNote(
          '"Not to impede" (Rule 8f): a yacht under 20 m must not impede a '
          'large vessel in a narrow channel – she has to take avoiding action '
          'early enough that the question of right of way never arises at all.',
          type: ColregNoteType.info,
        ),
        ColregHeading('Estimating distance'),
        ColregText(
          'The distance to the horizon in miles is roughly twice the square '
          'root of your height of eye in metres. On most leisure craft the '
          'horizon is between 2 and 5 miles away.',
        ),
      ],
    ),
  ],
);

// ── Chapter 3: Narrow channels and traffic separation ───────────

final _chapter3 = ColregSection(
  id: 'ch3',
  title: '3: Narrow channels and traffic separation schemes',
  blocks: [
    ColregText(
      'Rules 9 and 10 deal with navigation in narrow channels and traffic '
      'separation schemes (TSS). The principles in short:',
    ),
    ColregList([
      'keep to the right',
      'small craft must not impede others in the channel',
      'do not impede while fishing either',
      'do not cross a channel right ahead of a vessel using it',
      'use sound signals',
      'take care at bends where you cannot see',
      'do not anchor in the channel',
    ]),
  ],
  children: [
    ColregSection(
      id: 'rule9',
      title: 'Rule 9: Narrow channels',
      ruleNumber: '9',
      blocks: [
        ColregRuleBox(
          title: 'Rule 9: Narrow channels',
          text:
              'a) A vessel proceeding along the course of a narrow channel or '
              'fairway shall keep as near to the outer limit of the channel '
              'or fairway which lies on her starboard side as is safe and '
              'practicable.\n\n'
              'b) A vessel of less than 20 metres in length or a sailing '
              'vessel shall not impede the passage of a vessel which can '
              'safely navigate only within a narrow channel or fairway.\n\n'
              'c) A vessel engaged in fishing shall not impede the passage of '
              'any other vessel navigating within a narrow channel or '
              'fairway.\n\n'
              'd) A vessel shall not cross a narrow channel or fairway if '
              'such crossing impedes the passage of a vessel which can safely '
              'navigate only within it; the latter may use the sound signal '
              'prescribed in Rule 34(d) if in doubt as to the intention of '
              'the crossing vessel.\n\n'
              'e) Overtaking in a narrow channel requires sound signals (two '
              'prolonged blasts plus one or two short blasts).\n\n'
              'f) A vessel nearing a bend or an area where other vessels may '
              'be obscured shall navigate with particular alertness and '
              'sound the appropriate signal (one prolonged blast).\n\n'
              'g) Any vessel shall, if the circumstances admit, avoid '
              'anchoring in a narrow channel.',
        ),
        ColregDiagram('narrow_channel', 'Keeping to the channel correctly and incorrectly'),
        ColregText(
          'The word "narrow" is not defined in the COLREGs. Court decisions '
          'suggest an upper limit of about 2 miles. If a channel is marked '
          'with red and green buoys, large vessels will probably treat it as '
          'a narrow channel.',
        ),
        ColregNote(
          'The practical answer is to stay right outside the channel '
          'altogether, in shallow water where big ships cannot follow – where '
          'local rules allow it.',
          type: ColregNoteType.info,
        ),
      ],
    ),
    ColregSection(
      id: 'rule10',
      title: 'Rule 10: Traffic separation schemes',
      ruleNumber: '10',
      blocks: [
        ColregRuleBox(
          title: 'Rule 10: Traffic separation schemes (abridged)',
          text:
              'A vessel using a traffic separation scheme (TSS) shall:\n'
              '• proceed in the appropriate traffic lane in the general '
              'direction of traffic flow for that lane\n'
              '• so far as practicable keep clear of a traffic separation '
              'line or separation zone\n'
              '• normally join or leave a lane at the termination of the '
              'lane, but when joining or leaving from either side shall do so '
              'at as small an angle as practicable\n\n'
              'A vessel shall so far as practicable cross a lane on a heading '
              'as nearly as practicable at right angles to the general '
              'direction of traffic flow. Inshore traffic zones may be used '
              'by vessels under 20 metres, sailing vessels and vessels '
              'engaged in fishing.',
        ),
        ColregDiagram('tss_diagram', 'Traffic separation scheme – schematic'),
        ColregList([
          'Go with the direction of the lane',
          'Join at the ends',
          'Merge at a shallow angle',
          'If you must cross, cross at right angles',
        ]),
        ColregNote(
          'A sailing vessel must not impede a large vessel in a TSS, yet the '
          'large vessel is still required to give way to her. In practice: '
          'keep out of the way of big ships as best you can and get out of '
          'the scheme as quickly as possible.',
          type: ColregNoteType.warning,
        ),
      ],
    ),
  ],
);

// ── Chapter 4: Who gives way? ───────────────────────────────────

final _chapter4 = ColregSection(
  id: 'ch4',
  title: '4: Who gives way?',
  blocks: [
    ColregText(
      'This section (Rules 11–18) applies to vessels in sight of one another '
      'and contains rules that have remained essentially unchanged since 1863.',
    ),
  ],
  children: [
    ColregSection(
      id: 'rule12',
      title: 'Rule 12: Sailing vessels',
      ruleNumber: '12',
      blocks: [
        ColregRuleBox(
          title: 'Rule 12: Sailing vessels',
          text:
              'When two sailing vessels are approaching one another so as to '
              'involve risk of collision, one of them shall keep out of the '
              'way of the other as follows:\n\n'
              'i) When each has the wind on a different side, the vessel '
              'which has the wind on the port side shall keep out of the way '
              'of the other.\n\n'
              'ii) When both have the wind on the same side, the vessel which '
              'is to windward shall keep out of the way of the vessel which '
              'is to leeward.\n\n'
              'iii) If a vessel with the wind on the port side sees a vessel '
              'to windward and cannot determine with certainty whether the '
              'other vessel has the wind on the port or on the starboard '
              'side, she shall keep out of the way of the other.',
        ),
        ColregDiagram('sailboat_opposite_tack', 'Wind on different sides – port tack gives way'),
        ColregDiagram('sailboat_same_tack', 'Wind on the same side – windward gives way'),
        ColregText(
          'Point iii) applies only when the other vessel is upwind of you and '
          'you are on port tack. In other words: when in doubt, assume you '
          'are the one who has to give way.',
        ),
        ColregNote(
          'Even if you cannot see which tack the other boat is on, her '
          'look-out can see yours clearly. If you intend to resolve the '
          'situation by tacking, do it well in advance. When in doubt, the '
          'safest move is to bear away onto a parallel course and reassess.',
          type: ColregNoteType.warning,
        ),
      ],
    ),
    ColregSection(
      id: 'rule13',
      title: 'Rule 13: Overtaking',
      ruleNumber: '13',
      blocks: [
        ColregRuleBox(
          title: 'Rule 13: Overtaking',
          text:
              'a) Notwithstanding anything contained in the Rules of this '
              'Part, any vessel overtaking any other shall keep out of the '
              'way of the vessel being overtaken.\n\n'
              'b) A vessel shall be deemed to be overtaking when coming up '
              'with another vessel from a direction more than 22.5 degrees '
              'abaft her beam – that is, in such a position with reference to '
              'the vessel she is overtaking that at night she would see only '
              'the sternlight of that vessel but neither of her sidelights.\n\n'
              'c) When a vessel is in any doubt as to whether she is '
              'overtaking another, she shall assume that this is the case and '
              'act accordingly.\n\n'
              'd) Any subsequent alteration of the bearing between the two '
              'vessels shall not make the overtaking vessel a crossing vessel '
              'within the meaning of these Rules, or relieve her of the duty '
              'of keeping clear until she is finally past and clear.',
        ),
        ColregDiagram('overtaking_sector', 'The overtaking sector – 22.5° abaft the beam'),
        ColregText(
          'This rule takes absolute priority over the other steering and '
          'sailing rules, with the exception of Rule 19 (restricted '
          'visibility). A fast sailing yacht must give way to a slow motor '
          'boat if she is overtaking her.',
        ),
        ColregNote(
          'After the fatal collision between the dredger Bowbelle and the '
          'party boat Marchioness it emerged that overtaking between a large '
          'and a small vessel can produce dangerous wave interaction – the '
          'smaller craft can lose control and be drawn under the bow of the '
          'larger one.',
          type: ColregNoteType.story,
        ),
      ],
    ),
    ColregSection(
      id: 'rule14_15',
      title: 'Rules 14 and 15: Power-driven vessels',
      ruleNumber: '14-15',
      blocks: [
        ColregRuleBox(
          title: 'Rule 14: Head-on situation',
          text:
              'When two power-driven vessels are meeting on reciprocal or '
              'nearly reciprocal courses so as to involve risk of collision, '
              'each shall alter her course to starboard so that each shall '
              'pass on the port side of the other.',
        ),
        ColregDiagram('head_on_situation', 'Head-on meeting – both turn to starboard'),
        ColregNote(
          'GOLDEN RULE: if you are meeting almost head-on, NEVER turn to '
          'port. If the other vessel turns to port while you turn to '
          'starboard you are in serious trouble – either stop, or carry on '
          'through a full 180° turn and escape.',
          type: ColregNoteType.danger,
        ),
        ColregRuleBox(
          title: 'Rule 15: Crossing situation',
          text:
              'When two power-driven vessels are crossing so as to involve '
              'risk of collision, the vessel which has the other on her own '
              'starboard side shall keep out of the way and shall, if the '
              'circumstances of the case admit, avoid crossing ahead of the '
              'other vessel.',
        ),
        ColregDiagram('crossing_situation', 'Crossing – the vessel with the other on her starboard gives way'),
        ColregText(
          'This is the same as the "give way to the right" rule at a small '
          'roundabout. The give-way vessel should alter course to starboard '
          'or slow down – not try to cut across ahead.',
        ),
      ],
    ),
    ColregSection(
      id: 'rule16_17',
      title: 'Rules 16 and 17: Action by each vessel',
      ruleNumber: '16-17',
      blocks: [
        ColregText(
          'In COLREG language there are "give-way" vessels and "stand-on" '
          'vessels. There is no such thing as a vessel that "has right of '
          'way".',
        ),
        ColregRuleBox(
          title: 'Rule 16: Action by the give-way vessel',
          text:
              'Every vessel which is directed to keep out of the way of '
              'another vessel shall, so far as possible, take early and '
              'substantial action to keep well clear.',
        ),
        ColregRuleBox(
          title: 'Rule 17: Action by the stand-on vessel',
          text:
              'a) i) Where one of two vessels is to keep out of the way, the '
              'other shall keep her course and speed.\n'
              'ii) The latter vessel may however take action to avoid '
              'collision by her manoeuvre alone, as soon as it becomes '
              'apparent to her that the vessel required to keep out of the '
              'way is not taking appropriate action.\n\n'
              'b) When, from any cause, the vessel required to keep her '
              'course and speed finds herself so close that collision cannot '
              'be avoided by the action of the give-way vessel alone, she '
              'shall take such action as will best aid to avoid collision.\n\n'
              'c) A power-driven vessel which takes action in a crossing '
              'situation shall, if the circumstances admit, not alter course '
              'to port for a vessel on her own port side.',
        ),
        ColregHeading('The four stages of a developing situation'),
        ColregList([
          'Preparatory stage – no risk yet (vessels out of sight or far apart)',
          'First stage – duty to keep course and speed, and monitor how the '
              'situation develops',
          'Second stage – optional action: the look-out realises the other '
              'vessel is not giving way and may act (typically turn to '
              'starboard)',
          'Third stage – mandatory action: collision can no longer be avoided '
              'by the other vessel alone, and a turn to port becomes '
              'permissible',
        ], numbered: true),
        ColregNote(
          'A recommendation from the professional literature: on the open sea '
          'a stand-on vessel should not let another approach within about 12 '
          'of her own lengths without acting herself.',
          type: ColregNoteType.info,
        ),
      ],
    ),
    ColregSection(
      id: 'rule18',
      title: 'Rule 18: Responsibilities between vessels',
      ruleNumber: '18',
      blocks: [
        ColregText(
          'This rule sets the pecking order of who keeps out of whose way in '
          'open water, subject to Rules 9, 10 and 13:',
        ),
        ColregList([
          'vessel not under command',
          'vessel restricted in her ability to manoeuvre',
          'vessel constrained by her draught',
          'vessel engaged in fishing',
          'sailing vessel',
          'power-driven vessel',
          'seaplane or WIG craft',
        ], numbered: true),
        ColregNote(
          'Keep out of the way of anything HIGHER up this list than you are. '
          'A power-driven vessel gives way to a sailing vessel; a sailing '
          'vessel gives way to a vessel engaged in fishing.',
          type: ColregNoteType.info,
        ),
      ],
    ),
  ],
);

// ── Chapter 5: Fog! ─────────────────────────────────────────────

final _chapter5 = ColregSection(
  id: 'ch5',
  title: '5: Fog!',
  blocks: [
    ColregNote(
      'IN RESTRICTED VISIBILITY THERE IS NO SUCH THING AS A GIVE-WAY VESSEL '
      'OR A STAND-ON VESSEL. Rule 19 replaces Rules 11–18 entirely.',
      type: ColregNoteType.danger,
    ),
  ],
  children: [
    ColregSection(
      id: 'rule19',
      title: 'Rule 19: Conduct in restricted visibility',
      ruleNumber: '19',
      blocks: [
        ColregRuleBox(
          title: 'Rule 19: Conduct in restricted visibility',
          text:
              'a) This Rule applies to vessels not in sight of one another '
              'when navigating in or near an area of restricted visibility.\n\n'
              'b) Every vessel shall proceed at a safe speed adapted to the '
              'prevailing circumstances. A power-driven vessel shall have her '
              'engines ready for immediate manoeuvre.\n\n'
              'd) A vessel which detects by radar alone the presence of '
              'another vessel shall determine if a close-quarters situation '
              'is developing or risk of collision exists. If so, she shall '
              'take avoiding action in ample time, provided that when such '
              'action consists of an alteration of course, so far as possible '
              'the following shall be avoided:\n'
              '  i) an alteration of course to port for a vessel forward of '
              'the beam, other than for a vessel being overtaken\n'
              '  ii) an alteration of course towards a vessel abeam or abaft '
              'the beam\n\n'
              'e) A vessel which hears apparently forward of her beam the fog '
              'signal of another vessel, or which cannot avoid a '
              'close-quarters situation with a vessel forward of her beam, '
              'shall reduce her speed to the minimum at which she can be kept '
              'on course, and if necessary take all way off.',
        ),
        ColregText(
          'In practice this means you must not do anything that would '
          'increase the risk. Turned into positive advice, the rule says '
          'this:',
        ),
        ColregList([
          'Alter course to STARBOARD if a vessel is approaching from ahead',
          'Alter course to STARBOARD if she is approaching from the port side '
              'or from astern on the port quarter',
          'Alter course to PORT if she is approaching from the starboard side '
              'or from astern on the starboard quarter',
        ]),
        ColregDiagram('fog_radar_avoidance', 'Manoeuvring on radar in fog'),
        ColregNote(
          'Wahkuna (2003): both the yacht and the container ship Nedlloyd '
          'Vespucci had detected each other on radar at 6 miles. The yacht\'s '
          'skipper slowed down, believing the container ship would pass '
          'ahead. The container ship held 25 knots. Minutes later her bow '
          'struck the almost stationary yacht.',
          type: ColregNoteType.story,
        ),
        ColregHeading('Lord Justice Scrutton\'s rule (1933)'),
        ColregText(
          'You should be able to stop within half the distance you can see. '
          'This is only a rough guide – for a sailing vessel, keeping enough '
          'way on to manoeuvre matters more than slowing down mechanically.',
        ),
      ],
    ),
    ColregSection(
      id: 'fog_signals',
      title: 'Sound signals in restricted visibility',
      blocks: [
        ColregText(
          'Rule 35 sets out the sound signals for fog in detail. The basics '
          'for vessels under way:',
        ),
        ColregList([
          'Power-driven, making way: 1 prolonged blast (5 s) every 2 minutes',
          'Power-driven, stopped and making no way: 2 prolonged blasts every '
              '2 minutes',
          'Others (sailing vessels, vessels fishing, vessels towing): 1 '
              'prolonged + 2 short blasts (Morse D) every 2 minutes',
          'Vessel towed (last in the tow): 1 prolonged + 3 short blasts '
              '(Morse B) every 2 minutes',
        ]),
        ColregHeading('Vessels at anchor or aground'),
        ColregList([
          'At anchor (< 100 m): 5 seconds of bell every minute',
          'At anchor (> 100 m): 5 s bell forward + 5 s gong aft, every minute',
          'Aground (< 100 m): 3 strokes on the bell before and after the '
              'ringing, every minute',
          'Optional signal at anchor: 1 short + 1 prolonged + 1 short blast '
              '(Morse R)',
        ]),
        ColregNote(
          'Vessels under 12 m need not carry a bell or gong, but must make '
          'some other efficient sound signal at intervals of not more than '
          '2 minutes.',
          type: ColregNoteType.info,
        ),
      ],
    ),
  ],
);

// ── Chapter 6: Lights and shapes ────────────────────────────────

final _chapter6 = ColregSection(
  id: 'ch6',
  title: '6: Lights and day shapes',
  blocks: [
    ColregText('Lights in the COLREGs serve three purposes:'),
    ColregList([
      'They show that a vessel is there',
      'They show which way she is heading',
      'They show her status under the COLREGs',
    ], numbered: true),
    ColregText(
      'Day shapes are three-dimensional geometric shapes displayed during '
      'daylight in place of lights.',
    ),
  ],
  children: [
    ColregSection(
      id: 'rule21',
      title: 'Rule 21: Definitions of lights',
      ruleNumber: '21',
      blocks: [
        ColregList([
          '"Masthead light" – a white light placed over the fore and aft '
              'centreline, showing over an arc of 225°, from right ahead to '
              '22.5° abaft the beam on either side',
          '"Sidelights" – green to starboard, red to port, each showing over '
              'an arc of 112.5° (from right ahead to 22.5° abaft the beam)',
          '"Sternlight" – a white light at the stern showing over an arc of 135°',
          '"Towing light" – a yellow light with the same characteristics as '
              'a sternlight',
          '"All-round light" – a light showing over the whole horizon (360°)',
        ]),
        ColregDiagram('light_sectors', 'Sidelight sectors – green and red'),
        ColregNote(
          'A green sidelight means you are the stand-on vessel. A red '
          'sidelight means you must give way. This is the single most useful '
          'practical fact in the whole of the COLREGs.',
          type: ColregNoteType.danger,
        ),
        ColregDiagram('masthead_light', 'The masthead (steaming) light – covers the same sector as both sidelights'),
      ],
    ),
    ColregSection(
      id: 'lights_table',
      title: 'Who shows which lights and shapes',
      blocks: [
        ColregHeading('Power-driven vessel under way (Rule 23)'),
        ColregDiagram('power_vessel_lights', 'Power-driven vessel – sidelights, sternlight and masthead light'),
        ColregText(
          'Vessels under 50 m: 4 lights (green, red, white sternlight, white '
          'masthead light). Vessels over 50 m: a second masthead light, '
          'higher and further aft. Vessels under 20 m may combine the '
          'sidelights in one lantern. Vessels under 12 m may show an '
          'all-round white light plus sidelights.',
        ),
        ColregHeading('Sailing vessel under way (Rule 25)'),
        ColregDiagram('sailboat_lights', 'Sailing vessel – sidelights and sternlight, no masthead light'),
        ColregText(
          'Sailing vessels under 20 m may carry a combined lantern at the '
          'masthead (a tricolour), or optionally two all-round lights (red '
          'over green) at the masthead in addition to deck-level sidelights – '
          'but not together with a tricolour.',
        ),
        ColregNote(
          'A sailing vessel under sail AND engine at the same time '
          '(motorsailing) counts as a POWER-DRIVEN vessel. She must show a '
          'masthead light, and by day a black cone point down.',
          type: ColregNoteType.warning,
        ),
        ColregText(
          'Sailing vessels and rowing boats under 7 m: if they cannot carry '
          'proper lights, they must at least have an electric torch showing a '
          'white light ready to hand.',
        ),
        ColregHeading('Fishing vessels (Rule 26)'),
        ColregDiagram('trawler_lights', 'Trawler – green over white plus sidelights and sternlight'),
        ColregDiagram('fishing_lights', 'Other fishing – red over white'),
        ColregText(
          'Trawler (dragging a net): green over white all-round lights. Other '
          'fishing: red over white. By day: two black cones apex to apex.',
        ),
        ColregHeading('Vessels not under command and restricted in manoeuvring (Rule 27)'),
        ColregDiagram('not_under_command', 'Not under command – two red lights'),
        ColregDiagram('restricted_maneuverability', 'Restricted in ability to manoeuvre – red-white-red'),
        ColregText(
          'Not under command: 2 red all-round lights in a vertical line, 2 '
          'balls by day. Restricted in ability to manoeuvre (dredging, cable '
          'laying, replenishment): red-white-red, and by day '
          'ball-diamond-ball.',
        ),
        ColregHeading('Vessel constrained by her draught (Rule 28)'),
        ColregDiagram('draft_constrained', 'Three red lights in a vertical line, or a cylinder by day'),
        ColregHeading('Vessels at anchor and aground (Rule 30)'),
        ColregDiagram('anchored_vessel', 'At anchor – a white light forward (higher) and aft (lower)'),
        ColregText(
          'Vessels under 50 m may show a single all-round white light. By '
          'day: a black ball forward (vessels over 7 m). Aground: anchor '
          'lights plus 2 red lights in a vertical line, and 3 balls by day.',
        ),
        ColregHeading('Towing and pushing (Rule 24)'),
        ColregDiagram('towing_lights', 'Tow – two or three masthead lights plus a yellow towing light'),
        ColregText(
          'Towing vessel: 2 masthead lights in a vertical line (3 if the tow '
          'exceeds 200 m) plus a yellow towing light above the sternlight. '
          'Vessel towed: sidelights and sternlight, no masthead light. By day '
          '(tow over 200 m): a diamond shape on both the towing vessel and '
          'the last vessel towed.',
        ),
      ],
    ),
    ColregSection(
      id: 'visibility',
      title: 'Rule 22: Visibility of lights',
      ruleNumber: '22',
      blocks: [
        ColregText('Minimum ranges of visibility by size of vessel:'),
        ColregList([
          'Vessels ≥ 50 m: masthead 6 miles, sidelights and sternlight 3 miles',
          'Vessels 12–50 m: masthead 5 miles (3 miles if under 20 m), '
              'sidelights and sternlight 2 miles',
          'Vessels < 12 m: masthead 2 miles, sidelights 1 mile, sternlight '
              '2 miles',
        ]),
        ColregNote(
          'For small sailing yachts, keeping the lights effective is '
          'critical: scratched lenses, a weak battery, or heeling more than '
          'about 5° can cut the visible range badly – you can be effectively '
          'invisible until it is far too late.',
          type: ColregNoteType.warning,
        ),
        ColregNote(
          'Ouzo (2006): the bodies of three yachtsmen were recovered off the '
          'Isle of Wight. The ferry Pride of Bilbao is thought to have either '
          'struck the 25-foot yacht or capsized her with her wash. The yacht '
          'was not visible on the ferry\'s radar even though she carried a '
          'radar reflector.',
          type: ColregNoteType.story,
        ),
      ],
    ),
  ],
);

// ── Chapter 7: Signals and key points (summary) ─────────────────

final _chapter7 = ColregSection(
  id: 'ch7',
  title: '7: Manoeuvring signals and distress signals',
  blocks: [],
  children: [
    ColregSection(
      id: 'rule34',
      title: 'Rule 34: Manoeuvring and warning signals',
      ruleNumber: '34',
      blocks: [
        ColregText('In sight of one another, power-driven and under way:'),
        ColregList([
          '1 short blast = "I am altering my course to starboard"',
          '2 short blasts = "I am altering my course to port"',
          '3 short blasts = "I am operating astern propulsion"',
          '5 or more short rapid blasts = "I do not understand your '
              'intentions" or "I doubt whether you are taking sufficient '
              'action" (the warning signal)',
          '1 prolonged blast = approaching a bend or an obscured section of '
              'a channel',
        ]),
        ColregHeading('Overtaking in a narrow channel'),
        ColregList([
          '2 prolonged + 1 short blast = "I intend to overtake you on your '
              'starboard side"',
          '2 prolonged + 2 short blasts = "I intend to overtake you on your '
              'port side"',
          'Signal of agreement: prolonged-short-prolonged-short (Morse C)',
        ]),
        ColregNote(
          'A short blast is about 1 second. A prolonged blast is 4–6 seconds. '
          'These signals may be supplemented by light flashes of the same '
          'meaning (1, 2 or 3 flashes).',
          type: ColregNoteType.info,
        ),
      ],
    ),
    ColregSection(
      id: 'emergency',
      title: 'Rule 37 and Annex IV: Distress signals',
      blocks: [
        ColregText(
          'A vessel in distress shall use or exhibit these signals, either '
          'together or separately:',
        ),
        ColregList([
          'The signal SOS (...---...) by radiotelegraphy or any other method',
          'The spoken word "Mayday" by radiotelephony',
          'Rockets or shells throwing red stars, fired one at a time at short '
              'intervals',
          'A rocket parachute flare or a hand flare showing a red light',
          'An orange smoke signal',
          'Slow and repeated raising and lowering of arms outstretched to '
              'each side',
          'A square flag with a ball (or anything resembling a ball) above or '
              'below it',
          'The International Code signal of distress, N.C.',
          'Flames on the vessel (as from a burning tar barrel)',
          'Signals from emergency position-indicating radio beacons (EPIRBs) '
              'or SART transponders',
        ]),
        ColregNote(
          'Using a distress signal for any other purpose is prohibited under '
          'the COLREGs and is a criminal offence.',
          type: ColregNoteType.danger,
        ),
      ],
    ),
    ColregSection(
      id: 'key_points',
      title: 'Key points – quick summary',
      blocks: [
        ColregList([
          'Keep a proper look-out (Rule 5)',
          'Proceed at a safe speed (Rule 6)',
          'Assess the risk of collision systematically, using bearings and '
              'radar (Rule 7)',
          'Take avoiding action early and make it obvious (Rule 8)',
        ], numbered: true),
        ColregHeading('At sea, keep out of the way of (highest priority first):'),
        ColregList([
          'a vessel you are overtaking',
          'a vessel not under command',
          'a vessel restricted in her ability to manoeuvre',
          'a vessel constrained by her draught',
          'a vessel engaged in fishing',
          'a sailing vessel (if you are power-driven)',
        ]),
        ColregHeading('Power-driven vessels meeting:'),
        ColregList([
          'Head-on → both alter to STARBOARD',
          'Crossing → the vessel with the other on her STARBOARD side gives way',
        ]),
        ColregHeading('Sailing vessels meeting:'),
        ColregList([
          'Different tacks → the vessel with the wind on her PORT side gives way',
          'Same tack → the WINDWARD vessel keeps clear of the LEEWARD one',
        ]),
        ColregHeading('In fog:'),
        ColregList([
          'Make the fog signal (1 prolonged blast every 2 min under power, '
              'Morse D under sail)',
          'Slow down enough to hear the signals of other vessels',
          'No vessel "has right of way" – only Rule 19 applies',
        ]),
        ColregHeading('At night:'),
        ColregList([
          'Sailing vessel: sidelights + sternlight',
          'Power-driven under 50 m: sidelights + sternlight + 1 masthead light',
          'Motorsailing = power-driven (switch off the tricolour, switch on '
              'the masthead light)',
        ]),
        ColregHeading('When giving way:'),
        ColregList([
          'Do not cross ahead of the other vessel',
          'An alteration of course is usually more effective than a change of '
              'speed',
          'Make the alteration large enough for the other vessel to notice',
        ]),
        ColregHeading('When standing on:'),
        ColregNote(
          'The rule says the stand-on vessel "shall keep her course and '
          'speed... until it becomes apparent that the vessel required to '
          'keep out of the way is not taking appropriate action." This is '
          'MANDATORY, not optional or merely advisable.',
          type: ColregNoteType.danger,
        ),
      ],
    ),
  ],
);
