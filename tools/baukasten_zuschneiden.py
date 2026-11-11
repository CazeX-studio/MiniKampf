"""Schneidet die KI-Bildblätter (tools/vorlagen/) in einzelne Baukasten-Teile (assets/baukasten/).

Was das Werkzeug macht:
- stellt die Teile frei (auch wenn das Karomuster für „durchsichtig“ nur mitgemalt ist),
- schneidet jedes Teil einzeln aus und benennt es (Zuordnung über einen ungefähren Punkt im Blatt),
- verkleinert es auf Spielgröße (ein Feld ist im Spiel 64 x 32 Pixel),
- misst die Grundfläche (wie viele Felder breit und tief) und den Fußpunkt und schreibt beides
  nach tools/vorlagen/messung.json (Claude überträgt die Werte nach data/baukasten_teile.json).
Aufruf: python3 tools/baukasten_zuschneiden.py [BLATT …]   (braucht numpy, scipy und Pillow; ohne Angabe alle Blätter)
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

import look_pruefen

WURZEL = Path(__file__).resolve().parent.parent
VORLAGEN = WURZEL / "tools" / "vorlagen"
ZIEL = WURZEL / "assets" / "baukasten"
TW, TH = 64, 32
## Teile mit dunklem Innenraum: Das Freistellen hat dort Löcher gerissen
LOECHER_FUELLEN = ["go_schmiede_offen", "go_aufzug_unten"]
## Bodenrauten: so viel vom Rand weglassen (Anteil), damit der dunkle Rand der gemalten Kacheln verschwindet
BODEN_RAND = 0.07

# Blatt -> Maßstab (Spielpixel pro Bildpixel) und Teile mit ungefährer Mitte im Blatt.
# Die Maßstäbe sind so gewählt, dass die Blätter zueinander passen (Häuser, Stände, Kleinkram, Bäume).
BLAETTER = {
	"gebaeude": {"massstab": 0.6, "schnitt": [(800, 1440, 487)], "teile": {
		"gilde": (400, 440), "wegrast": (1120, 240), "haus_klein": (1020, 660), "haus_mittel": (1560, 600)}},
	"markt": {"massstab": 0.45, "teile": {
		"marktstand_rot": (360, 260), "marktstand_blau": (940, 220), "bingos_stand": (600, 660), "brunnen": (1460, 540)}},
	"besonderes": {"massstab": 0.6, "teile": {
		"statue_der_fuenf": (360, 340), "torbogen": (880, 330), "sechstes_tor": (1310, 340),
		"bruecke": (540, 800), "mauer": (1190, 800)}},
	"pavillons": {"massstab": 0.55, "teile": {
		"pavillon_messinghafen": (280, 270), "pavillon_glutoase": (780, 270), "pavillon_gruenwacht": (1280, 270),
		"pavillon_arkanum": (510, 680), "pavillon_nebelinseln": (1040, 680)}},
	"kleinkram": {"massstab": 0.38, "teile": {
		"laterne": (190, 250), "fackelschale": (530, 300), "banner": (810, 250), "bank": (1210, 350), "fass": (1600, 370),
		"kiste": (180, 730), "zaun": (510, 730), "wegweiser": (800, 670), "auftragsbrett": (1140, 680), "mauerruine": (1550, 710)}},
	"pflanzen": {"massstab": 0.44, "teile": {
		"baum": (230, 340), "baum_herbst": (670, 340), "tanne": (1100, 360), "tanne_gross": (1520, 300),
		"busch": (230, 740), "busch_bluete": (680, 740), "blumen": (1100, 760), "grasbueschel": (1540, 760)}},
	"splitter": {"massstab": 0.41, "roter_rand": True, "teile": {
		"splitterkreis": (440, 230), "krater_frisch": (1320, 260), "krater_spaet": (680, 650), "sternsplitter": (1460, 690)}},
	"boden": {"boden": True, "teile": {
		"gras_1": (274, 190), "gras_2": (820, 190), "pflaster_1": (1360, 190), "pflaster_2": (1896, 190),
		"platz": (274, 510), "erde": (820, 510), "wasser_1": (1360, 510), "wasser_2": (1896, 510)}},
	# Kreuzweg und Kreuzwegfelder (GRAFIK_AUFTRAG.md, Teil C). "massstaebe": Maßstab einzelner Teile, weil die Motive
	# auf diesen Blättern unterschiedlich groß gemalt sind. "saum": durchsichtig gespeichertes Blatt mit rotem Saum.
	"kreuzweg_k1": {"massstab": 0.38, "saum": True, "look": True, "teile": {
		"mauer_kurve": (467, 348), "mauer_ende": (1178, 380), "mauer_treppe": (1846, 358)}},
	"kreuzweg_k1b": {"massstab": 0.33, "stein": (0.86, 0.86, 0.9), "look": True, "teile": {
		"mauer_gerade_a": (540, 330), "mauer_gerade_b": (1450, 330)}},
	"kreuzweg_k2": {"massstab": 0.32, "look": True, "massstaebe": {"seitentor": 0.38, "wachhaeuschen": 0.4}, "teile": {
		"banner_messinghafen": (438, 147), "banner_glutoase": (749, 147), "banner_gruenwacht": (1070, 147),
		"banner_arkanum": (1387, 147), "banner_nebelinseln": (1708, 147), "seitentor": (717, 516), "wachhaeuschen": (1390, 489)}},
	"kreuzweg_k3": {"massstab": 0.38, "saum": True, "look": True, "massstaebe": {"bankhaus": 0.36, "hutmacher": 0.42}, "teile": {
		"bankhaus": (418, 358), "bingos_laden": (1195, 348), "hutmacher": (1846, 358)}},
	"kreuzweg_k4": {"massstab": 0.38, "look": True, "massstaebe": {"eckhaus": 0.34}, "teile": {
		"haus_gross": (489, 434), "eckhaus": (1542, 456)}},
	"kreuzweg_k5": {"massstab": 0.26, "look": True, "massstaebe": {"wegelaterne": 0.25}, "teile": {
		"wegelaterne": (424, 413), "festbuehne": (1401, 413)}},
	"kreuzweg_k7": {"massstab": 0.2, "saum": True, "look": True, "teile": {
		"strohpuppe": (282, 380), "zielscheibe": (695, 402), "waffenstaender": (1184, 380), "feuerstelle": (1825, 380)}},
	"kreuzweg_k8": {"massstab": 0.19, "look": True, "massstaebe": {"festlaternen": 0.3, "dornenranken": 0.22}, "teile": {
		"blumenkasten": (239, 489), "festlaternen": (983, 348), "dornenranken": (1835, 445)}},
	"kreuzwegfelder_z1a": {"boden": True, "teile": {"blumenwiese_1": (545, 355), "blumenwiese_2": (1630, 355)}},
	"kreuzwegfelder_z1b": {"massstab": 0.2, "look": True, "massstaebe": {"heuballen": 0.17}, "teile": {
		"steg": (711, 391), "heuballen": (1683, 391)}},
	# Rastplatz und Hirschtal. "kern": durchsichtig gespeichertes Blatt mit farbigem Saum, nur der feste Kern bleibt.
	"weg_r1": {"massstab": 0.3, "kern": True, "look": True, "massstaebe": {"holzbank": 0.4}, "teile": {
		"lagerfeuer": (480, 270), "haendlerstand": (1120, 210), "holzbank": (455, 690), "zelt": (1170, 620)}},
	"weg_z2": {"massstab": 0.3, "look": True, "massstaebe": {"waldrand": 0.42, "jaegerhuette": 0.33, "baumstamm": 0.35,
		"geweih_wegweiser": 0.45}, "teile": {
		"waldrand": (450, 190), "bach_steine": (275, 515), "holzbruecke": (755, 510), "jaegerhuette": (1380, 280),
		"baumstamm": (335, 760), "dornengebuesch": (850, 760), "geweih_wegweiser": (1225, 710)}},
}
# Grünwacht, Glutoase und Vulkanschmiede: Maßstab je Teil aus der Fläche im Bildauftrag
BLAETTER.update({'gruenwacht_g2': {'massstab': 0.3,
                   'kern': True,
                   'look': True,
                   'massstaebe': {'gw_plattform_rund': 0.604,
                                  'gw_plattform_eckig': 0.41,
                                  'gw_haengebruecke': 0.559,
                                  'gw_haengebruecke_lang': 0.437,
                                  'gw_gelaender': 0.552,
                                  'gw_strickleiter': 0.486,
                                  'gw_seilaufzug': 0.4},
                   'teile': {'gw_plattform_rund': (331, 209),
                             'gw_plattform_eckig': (874, 208),
                             'gw_haengebruecke': (1294, 187),
                             'gw_haengebruecke_lang': (1768, 161),
                             'gw_gelaender': (614, 554),
                             'gw_strickleiter': (972, 540),
                             'gw_seilaufzug': (1354, 512)}},
 'gruenwacht_g3': {'massstab': 0.3,
                   'kern': True,
                   'look': True,
                   'massstaebe': {'gw_gasthaus': 0.584,
                                  'gw_bank': 0.611,
                                  'gw_stand_salbei': 0.452,
                                  'gw_esches_huette': 0.593,
                                  'gw_tildas_stall': 0.555,
                                  'gw_wohnbaumhaus': 0.561},
                   'teile': {'gw_gasthaus': (466, 189),
                             'gw_bank': (1067, 182),
                             'gw_stand_salbei': (1639, 170),
                             'gw_esches_huette': (466, 543),
                             'gw_tildas_stall': (1105, 542),
                             'gw_wohnbaumhaus': (1722, 526)}},
 'gruenwacht_g4': {'massstab': 0.3,
                   'kern': True,
                   'look': True,
                   'massstaebe': {'gw_urbaum': 0.52,
                                  'gw_grosse_wurzel': 0.393,
                                  'gw_hoehleneingang': 0.345,
                                  'gw_leuchtpilze_klein': 0.492,
                                  'gw_leuchtpilze_mittel': 0.312,
                                  'gw_leuchtpilze_gross': 0.356},
                   'teile': {'gw_urbaum': (433, 229),
                             'gw_grosse_wurzel': (1124, 216),
                             'gw_hoehleneingang': (1773, 198),
                             'gw_leuchtpilze_klein': (526, 607),
                             'gw_leuchtpilze_mittel': (934, 587),
                             'gw_leuchtpilze_gross': (1501, 555)}},
 'gruenwacht_g5': {'massstab': 0.3,
                   'kern': True,
                   'look': True,
                   'massstaebe': {'gw_zielscheibe': 0.347,
                                  'gw_zielscheibe_haengend': 0.284,
                                  'gw_zielscheibe_tier': 0.293,
                                  'gw_pfadmarke': 0.365,
                                  'gw_baumtor': 0.246,
                                  'gw_pfad_tiefwurzel': 0.217},
                   'teile': {'gw_zielscheibe': (495, 147),
                             'gw_zielscheibe_haengend': (879, 126),
                             'gw_zielscheibe_tier': (1265, 129),
                             'gw_pfadmarke': (1661, 134),
                             'gw_baumtor': (724, 479),
                             'gw_pfad_tiefwurzel': (1445, 495)}},
 'gruenwacht_g6': {'massstab': 0.3,
                   'kern': True,
                   'look': True,
                   'massstaebe': {'gw_bruecken_laterne': 0.242,
                                  'gw_pilzkoerbe': 0.211,
                                  'gw_kraeuterkisten': 0.17,
                                  'gw_jagdtrophaee': 0.212,
                                  'gw_baumstumpf': 0.176,
                                  'gw_farn': 0.152,
                                  'gw_rowans_grab': 0.219,
                                  'gw_bienenstock': 0.177},
                   'teile': {'gw_bruecken_laterne': (342, 186),
                             'gw_pilzkoerbe': (820, 180),
                             'gw_kraeuterkisten': (1297, 173),
                             'gw_jagdtrophaee': (1791, 167),
                             'gw_baumstumpf': (347, 538),
                             'gw_farn': (829, 534),
                             'gw_rowans_grab': (1331, 537),
                             'gw_bienenstock': (1803, 495)}},
 'gruenwacht_z3': {'massstab': 0.3,
                   'kern': True,
                   'look': True,
                   'massstaebe': {'gw_laubbaum': 0.399,
                                  'gw_jaegerpfad': 0.289,
                                  'gw_hochsitz': 0.421,
                                  'gw_lichtung': 0.443,
                                  'gw_fallenmarke': 0.395,
                                  'gw_steinkreis': 0.342},
                   'teile': {'gw_laubbaum': (539, 183),
                             'gw_jaegerpfad': (1077, 207),
                             'gw_hochsitz': (1577, 187),
                             'gw_lichtung': (577, 544),
                             'gw_fallenmarke': (1045, 555),
                             'gw_steinkreis': (1545, 543)}},
 'gruenwacht_z4': {'massstab': 0.3,
                   'kern': True,
                   'look': True,
                   'massstaebe': {'gw_dunkler_baum': 0.296,
                                  'gw_wurzelbruecke': 0.302,
                                  'gw_wurzelhoehle': 0.392,
                                  'gw_splitterkristall_klein': 0.457,
                                  'gw_splitterkristall_gross': 0.456,
                                  'gw_verdorrter_baum': 0.38,
                                  'gw_nebelboden': 0.431},
                   'teile': {'gw_dunkler_baum': (235, 282),
                             'gw_wurzelbruecke': (736, 347),
                             'gw_wurzelhoehle': (1270, 313),
                             'gw_splitterkristall_klein': (166, 824),
                             'gw_splitterkristall_gross': (474, 785),
                             'gw_verdorrter_baum': (867, 751),
                             'gw_nebelboden': (1275, 848)}},
 'gruenwacht_p1': {'massstab': 0.3,
                   'kern': True,
                   'look': True,
                   'massstaebe': {'gw_wurzelwand': 0.252,
                                  'gw_pilzboden': 0.259,
                                  'gw_lichtlaterne': 0.238,
                                  'gw_wurzelsplitter': 0.231},
                   'teile': {'gw_wurzelwand': (434, 262),
                             'gw_pilzboden': (1166, 321),
                             'gw_lichtlaterne': (377, 774),
                             'gw_wurzelsplitter': (1107, 774)}},
 'glutoase_o1b': {'massstab': 0.3,
                  'kern': True,
                  'look': True,
                  'massstaebe': {'go_terrassenkante': 0.285, 'go_treppe': 0.226, 'go_treppe_ecke': 0.23},
                  'teile': {'go_terrassenkante': (368, 355), 'go_treppe': (1107, 389), 'go_treppe_ecke': (1810, 373)}},
 'glutoase_o2': {'massstab': 0.3,
                 'kern': True,
                 'look': True,
                 'massstaebe': {'go_brunnen': 0.481,
                                'go_tanzplatz': 0.618,
                                'go_basar_a': 0.537,
                                'go_basar_b': 0.552,
                                'go_krankenzelt': 0.407,
                                'go_karawanenplatz': 0.358},
                 'teile': {'go_brunnen': (281, 227),
                           'go_tanzplatz': (845, 243),
                           'go_basar_a': (1273, 223),
                           'go_basar_b': (1605, 226),
                           'go_krankenzelt': (450, 656),
                           'go_karawanenplatz': (1241, 653)}},
 'glutoase_o3': {'massstab': 0.3,
                 'kern': 225,
                 'look': True,
                 'massstaebe': {'go_lehmhaus_gross': 0.584,
                                'go_lehmhaus_klein': 0.617,
                                'go_gasthaus': 0.594,
                                'go_bank': 0.536,
                                'go_tareks_laden': 0.523},
                 'teile': {'go_lehmhaus_gross': (264, 258),
                           'go_lehmhaus_klein': (706, 316),
                           'go_gasthaus': (1216, 282),
                           'go_bank': (423, 744),
                           'go_tareks_laden': (995, 765)}},
 'glutoase_o4': {'massstab': 0.3,
                 'kern': True,
                 'look': True,
                 'massstaebe': {'go_clan_werkstatt': 0.504,
                                'go_esse': 0.472,
                                'go_amboss': 0.504,
                                'go_wassertrog': 0.447,
                                'go_werkzeugwand': 0.459,
                                'go_brakkus_werkstatt': 0.376},
                 'teile': {'go_clan_werkstatt': (323, 238),
                           'go_esse': (828, 186),
                           'go_amboss': (1099, 251),
                           'go_wassertrog': (1359, 252),
                           'go_werkzeugwand': (1641, 246),
                           'go_brakkus_werkstatt': (871, 613)}},
 'glutoase_o5': {'massstab': 0.3,
                 'kern': True,
                 'look': True,
                 'massstaebe': {'go_hadraks_schmiede': 0.456,
                                'go_kettenamboss': 0.338,
                                'go_schmiede_zu': 0.364,
                                'go_schmiede_offen': 0.356,
                                'go_bergpfad': 0.337},
                 'teile': {'go_hadraks_schmiede': (628, 294),
                           'go_kettenamboss': (1378, 342),
                           'go_schmiede_zu': (341, 731),
                           'go_schmiede_offen': (905, 732),
                           'go_bergpfad': (1455, 731)}},
 'glutoase_o6': {'massstab': 0.3,
                 'kern': True,
                 'look': True,
                 'massstaebe': {'go_tor_steppe': 0.335,
                                'go_tor_duerrewald': 0.333,
                                'go_aufzug_unten': 0.394,
                                'go_aufzug_oben': 0.344,
                                'go_sonnensegel': 0.392},
                 'teile': {'go_tor_steppe': (469, 211),
                           'go_tor_duerrewald': (1308, 212),
                           'go_aufzug_unten': (316, 638),
                           'go_aufzug_oben': (908, 622),
                           'go_sonnensegel': (1473, 653)}},
 'glutoase_o7': {'massstab': 0.3,
                 'kern': True,
                 'look': True,
                 'massstaebe': {'go_palme_gross': 0.316,
                                'go_palme_klein': 0.216,
                                'go_tonkruege': 0.217,
                                'go_teppiche': 0.183,
                                'go_kohlesaecke': 0.181,
                                'go_fackel': 0.285,
                                'go_tanzlaterne': 0.256},
                 'teile': {'go_palme_gross': (337, 234),
                           'go_palme_klein': (716, 289),
                           'go_tonkruege': (1078, 296),
                           'go_teppiche': (1468, 324),
                           'go_kohlesaecke': (450, 714),
                           'go_fackel': (857, 674),
                           'go_tanzlaterne': (1274, 666)}},
 'glutoase_z5': {'massstab': 0.3,
                 'kern': True,
                 'look': True,
                 'massstaebe': {'go_steppengras': 0.34,
                                'go_gras_zu_sand': 0.337,
                                'go_trockenbusch': 0.4,
                                'go_felsbrocken': 0.304,
                                'go_karawanenspur': 0.282,
                                'go_verlassener_wagen': 0.288},
                 'teile': {'go_steppengras': (285, 308),
                           'go_gras_zu_sand': (771, 314),
                           'go_trockenbusch': (1256, 309),
                           'go_felsbrocken': (244, 711),
                           'go_karawanenspur': (747, 717),
                           'go_verlassener_wagen': (1236, 691)}},
 'glutoase_z6': {'massstab': 0.3,
                 'kern': True,
                 'look': True,
                 'massstaebe': {'go_duene': 0.39,
                                'go_duenenkamm': 0.316,
                                'go_wasserstelle': 0.494,
                                'go_kakteen': 0.315,
                                'go_ruine': 0.36,
                                'go_sternenduene': 0.317},
                 'teile': {'go_duene': (440, 139),
                           'go_duenenkamm': (1100, 135),
                           'go_wasserstelle': (300, 432),
                           'go_kakteen': (754, 408),
                           'go_ruine': (1220, 417),
                           'go_sternenduene': (748, 794)}},
 'glutoase_z7': {'massstab': 0.3,
                 'kern': True,
                 'look': True,
                 'massstaebe': {'go_erkaltete_lava': 0.363,
                                'go_lavarinne': 0.294,
                                'go_felsgrat': 0.306,
                                'go_heisse_quelle': 0.322,
                                'go_obsidian': 0.312,
                                'go_kraterrand': 0.249},
                 'teile': {'go_erkaltete_lava': (234, 254),
                           'go_lavarinne': (737, 239),
                           'go_felsgrat': (1365, 211),
                           'go_heisse_quelle': (209, 677),
                           'go_obsidian': (640, 663),
                           'go_kraterrand': (1314, 638)}},
 'schmiede_v1': {'massstab': 0.3,
                 'kern': True,
                 'look': True,
                 'massstaebe': {'vs_eisenwand': 0.261, 'vs_esse': 0.287, 'vs_kettenwinde': 0.299},
                 'teile': {'vs_eisenwand': (403, 435), 'vs_esse': (1177, 369), 'vs_kettenwinde': (1897, 443)}},
 'schmiede_v2': {'massstab': 0.3,
                 'kern': True,
                 'look': True,
                 'massstaebe': {'vs_kettenbruecke': 0.203, 'vs_anker': 0.249, 'vs_kuehlbecken': 0.268},
                 'teile': {'vs_kettenbruecke': (508, 362), 'vs_anker': (1306, 364), 'vs_kuehlbecken': (1892, 478)}},
 'gruenwacht_g1': {'boden': True,
                   'teile': {'gw_waldboden_1': (189, 169),
                             'gw_waldboden_2': (549, 169),
                             'gw_moos_1': (907, 170),
                             'gw_moos_2': (1265, 170),
                             'gw_wurzelboden_1': (1624, 169),
                             'gw_wurzelboden_2': (1984, 169),
                             'gw_laub_1': (189, 530),
                             'gw_laub_2': (549, 530),
                             'gw_planken_1': (907, 530),
                             'gw_planken_2': (1265, 530),
                             'gw_bach_1': (1624, 530),
                             'gw_bach_2': (1984, 530)}},
 'glutoase_o1': {'boden': True,
                 'teile': {'go_sand_1': (224, 264),
                           'go_sand_2': (667, 264),
                           'go_lehm_1': (1111, 263),
                           'go_lehm_2': (1552, 263),
                           'go_gras_1': (224, 704),
                           'go_gras_2': (667, 704),
                           'go_wasser_1': (1111, 704),
                           'go_wasser_2': (1552, 704)}},
 'schmiede_v1a': {'boden': True, 'teile': {'vs_stein_1': (443, 476), 'vs_stein_2': (1330, 476)}},
 # Gasthaus Wegrast innen (A12a, Auftrag IN1): Wände im Maßstab der linken Wand (4 Felder lang), die rechte Wand ist kürzer gemalt
 'innen_wegrast_1': {'massstab': 0.327,
                     'kern': True,
                     'look': True,
                     'massstaebe': {'in_wr_teppich': 0.27},
                     'teile': {'in_wr_wand_links': (280, 400),
                               'in_wr_wand_regal': (700, 320),
                               'in_wr_ecke': (985, 420),
                               'in_wr_tuer': (1310, 400),
                               'in_wr_teppich': (1265, 835)}},
 'innen_wegrast_1b': {'boden': True, 'datei': 'innen_wegrast_1',
                      'teile': {'in_wr_dielen_1': (180, 850),
                                'in_wr_dielen_2': (515, 850),
                                'in_wr_dielen_3': (845, 850)}},
 # Gasthaus Wegrast innen (A12a, Auftrag IN2): Einrichtung
 'innen_wegrast_2': {'massstab': 0.3,
                     'kern': True,
                     'look': True,
                     'teile': {'in_wr_theke': (300, 200),
                               'in_wr_fassregal': (830, 190),
                               'in_wr_kamin': (1270, 260),
                               'in_wr_tisch': (290, 480),
                               'in_wr_langer_tisch': (800, 490),
                               'in_wr_treppe': (260, 800),
                               'in_wr_brett': (720, 800),
                               'in_wr_hocker_kisten': (1250, 860)}},
 # Dürrewald (A13b, Auftrag P2): Pflanzen und Grenzstein; Maßstab je Teil so, dass die gemalte Grundfläche auf die Felder passt
 'duerrewald_teile': {'massstab': 0.24,
                      'kern': True,
                      'look': True,
                      'massstaebe': {'dw_duerrer_baum': 0.242,
                                     'dw_steppenbaum': 0.281,
                                     'dw_erwachender_busch': 0.272,
                                     'dw_grenzstein': 0.237,
                                     'dw_versandeter_zaun': 0.231,
                                     'dw_umgestuerzter_baum': 0.194},
                      'teile': {'dw_duerrer_baum': (200, 300),
                                'dw_steppenbaum': (760, 250),
                                'dw_erwachender_busch': (1310, 370),
                                'dw_grenzstein': (190, 800),
                                'dw_versandeter_zaun': (600, 800),
                                'dw_umgestuerzter_baum': (1180, 780)}},
 # Dürrewald (A13b, Auftrag P1): Übergangsböden Sand -> Wald
 'boden_duerrewald': {'boden': True, 'schwarz': True,
                      'teile': {'dw_steppengras_1': (224, 200),
                                'dw_steppengras_2': (666, 200),
                                'dw_trockengras_1': (1110, 200),
                                'dw_trockengras_2': (1552, 200),
                                'dw_erde_1': (224, 645),
                                'dw_erde_2': (666, 645),
                                'dw_waldrand_1': (1110, 645),
                                'dw_waldrand_2': (1552, 645)}}})
BLAETTER["gruenwacht_halle"] = {"massstab": 0.2, "kern": True, "look": True, "massstaebe": {"gw_dornfeders_halle": 0.2},
	"teile": {"gw_dornfeders_halle": (720, 540)}}


def freistellen(bild, roter_rand=False):
	"""RGBA-Feld mit echtem Hintergrund; ein mitgemaltes Karomuster wird entfernt, graue Schatten darauf halb durchsichtig."""
	a = np.array(bild.convert("RGBA")).astype(np.int16)
	if bild.mode == "RGBA" and a[..., 3].min() == 0:
		if roter_rand:
			# Nur bei Blättern mit rotem Schimmer am Rand: halbdurchsichtige, stark rote Pixel entfernen
			r, g, b, alpha = a[..., 0], a[..., 1], a[..., 2], a[..., 3]
			a[(r > g + 80) & (r > b + 40) & (alpha < 255), 3] = 0
		return a.astype(np.uint8)
	rgb = a[..., :3]
	hoch, tief = rgb.max(-1), rgb.min(-1)
	# Hintergrund: helle, graue Flächen, die mit dem Rand verbunden sind
	grau = (hoch - tief < 22) & (tief > 150)
	lab, _ = ndimage.label(grau)
	rand = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
	hinten = np.isin(lab, list(rand))
	# Eingeschlossene Karo-Löcher (zwischen Ästen, unter Planen): grau-weiß und mit vielen fast weißen Pixeln
	loch = (hoch - tief < 16) & (tief > 205) & ~hinten
	ll, ln = ndimage.label(loch)
	if ln:
		groesse = ndimage.sum(loch, ll, range(1, ln + 1))
		weiss = ndimage.sum(loch & (tief > 244), ll, range(1, ln + 1))
		hinten |= np.isin(ll, [i + 1 for i in range(ln) if groesse[i] >= 25 and weiss[i] > 0.2 * groesse[i]])
	aus = a.copy()
	aus[..., 3] = 255
	hell = hinten & (tief > 214)
	aus[hell, 3] = 0
	schatten = hinten & ~hell
	aus[schatten, 3] = np.clip((235 - tief[schatten]) * 2.2, 0, 255)
	aus[schatten, :3] = 0
	return aus.astype(np.uint8)


def saum_entfernen(bild):
	"""Durchsichtig gespeichertes Blatt: der weiche rote Saum außen fliegt raus, das Innere der Teile wird ganz deckend."""
	a = np.array(bild.convert("RGBA")).astype(np.int16)
	r, g, b, alpha = a[..., 0], a[..., 1], a[..., 2], a[..., 3]
	a[(alpha < 128) & (r > g + 80) & (r > b + 40), 3] = 0
	a[ndimage.binary_fill_holes(a[..., 3] >= 128), 3] = 255
	return a.astype(np.uint8)


def kern_behalten(bild, schwelle=128):
	"""Durchsichtig gespeichertes Blatt: alles Halbdurchsichtige außen fliegt raus, das Innere wird ganz deckend."""
	a = np.array(bild.convert("RGBA")).copy()
	a[..., 3] = np.where(ndimage.binary_fill_holes(a[..., 3] >= schwelle), 255, 0)
	return a


def stein_angleichen(a, faktor):
	"""Färbt nur steinfarbene Pixel um; Banner, Blätter und Umriss bleiben."""
	f = a.astype(np.float32)
	r, g, b = f[..., 0], f[..., 1], f[..., 2]
	maske = (abs(r - b) < 75) & (r > 70) & (g > b - 5) & (r - g < 45) & (g - r < 5)
	f[..., :3][maske] = np.clip(f[..., :3][maske] * np.array(faktor, dtype=np.float32), 0, 255)
	return f.astype(np.uint8)


def teile_finden(a, schnitte):
	"""Zusammenhängende Teile (Labels) im Blatt; kleine Krümel fallen weg."""
	m = a[..., 3] > 40
	ml, mn = ndimage.label(m)
	groesse = ndimage.sum(m, ml, range(1, mn + 1))
	m = np.isin(ml, [i + 1 for i, g in enumerate(groesse) if g >= 150])
	for x0, x1, y in schnitte:
		m[y - 4:y + 5, x0:x1] = False
	lab, n = ndimage.label(ndimage.binary_dilation(m, iterations=2))
	lab[~m] = 0
	stuecke = []
	for i, sl in enumerate(ndimage.find_objects(lab)):
		if sl is not None and (lab[sl] == i + 1).sum() >= 1500:
			stuecke.append((i + 1, sl))
	return lab, stuecke


def naechstes(stuecke, punkt):
	def abstand(st):
		sl = st[1]
		cy, cx = (sl[0].start + sl[0].stop) / 2, (sl[1].start + sl[1].stop) / 2
		return (cx - punkt[0]) ** 2 + (cy - punkt[1]) ** 2
	return min(stuecke, key=abstand)


def messen(teil):
	"""Grundfläche und Fußpunkt (Mitte der Grundfläche) aus der unteren Spitze und der Breite unten."""
	alpha = np.array(teil)[..., 3]
	fest = alpha > 200
	zeilen = np.where(fest.any(1))[0]
	unten = zeilen.max()
	spitze_x = float(np.where(fest[unten])[0].mean())
	# Breite der Grundfläche: unteres Drittel des Bildes
	bereich = fest[max(0, int(unten - (unten - zeilen.min()) * 0.3)):unten + 1]
	spalten = np.where(bereich.any(0))[0]
	links, rechts = spalten.min(), spalten.max()
	w = max(1, round((spitze_x - links) / (TW / 2)))
	h = max(1, round((rechts - spitze_x) / (TW / 2)))
	# Mitte der Grundfläche (wie im Spiel: von der vorderen Spitze aus)
	fuss = [round(spitze_x + (h - w) * TW / 4), round(unten - (w + h) * TH / 4)]
	return [w, h], fuss


def boden_teil(a, sl, lab, i):
	"""Bodenraute: nur die Oberseite (ohne Dicke und ohne dunklen Rand), genau 64 x 32, mit Rautenmaske."""
	stueck = a[sl].copy()
	stueck[lab[sl] != i, 3] = 0
	bild = Image.fromarray(stueck)
	breite = bild.width
	rx, ry = breite * BODEN_RAND, breite / 2 * BODEN_RAND
	oben = bild.crop((round(rx), round(ry), round(breite - rx), round(breite / 2 - ry))).resize((TW, TH), Image.LANCZOS)
	maske = Image.new("L", (TW, TH), 0)
	from PIL import ImageDraw
	ImageDraw.Draw(maske).polygon([(TW / 2, 0), (TW, TH / 2), (TW / 2, TH), (0, TH / 2)], fill=255)
	ergebnis = Image.new("RGBA", (TW, TH), (0, 0, 0, 0))
	ergebnis.paste(oben.convert("RGB"), (0, 0), maske)
	return ergebnis


def main():
	namen = sys.argv[1:] or list(BLAETTER)
	datei = VORLAGEN / "messung.json"
	messung = json.loads(datei.read_text(encoding="utf-8"))
	regeln = look_pruefen.lade_regeln()
	for blatt in namen:
		info = BLAETTER[blatt]
		# "datei": ein anderes Blatt, z. B. wenn auf einem Blatt Böden und Teile zusammen liegen
		bild = Image.open(VORLAGEN / f"{info.get('datei', blatt)}.png")
		if info.get("schwarz"):
			# Schwarzer statt durchsichtiger Hintergrund: alles, was nicht fast schwarz ist, gehört zum Motiv
			a = np.array(bild.convert("RGBA"))
			fest = ndimage.binary_fill_holes(ndimage.binary_closing(a[..., :3].max(-1) > 40, iterations=3))
			a[..., 3] = np.where(fest, 255, 0)
		elif info.get("kern"):
			# "kern": True oder die Deckkraft, ab der ein Pixel zum Motiv zählt; Blätter ohne Durchsichtigkeit werden freigestellt
			a = kern_behalten(bild, 128 if info["kern"] is True else info["kern"]) if bild.mode == "RGBA" else freistellen(bild)
		else:
			a = saum_entfernen(bild) if info.get("saum") else freistellen(bild, info.get("roter_rand", False))
		if info.get("stein"):
			a = stein_angleichen(a, info["stein"])
		lab, stuecke = teile_finden(a, info.get("schnitt", []))
		for name, punkt in info["teile"].items():
			i, sl = naechstes(stuecke, punkt)
			if info.get("boden"):
				boden_teil(a, sl, lab, i).save(ZIEL / "boden" / f"{name}.png")
				continue
			stueck = a[sl].copy()
			stueck[lab[sl] != i, 3] = 0
			bild = Image.fromarray(stueck)
			s = info.get("massstaebe", {}).get(name, info["massstab"])
			bild = bild.resize((max(1, round(bild.width * s)), max(1, round(bild.height * s))), Image.LANCZOS)
			if name in LOECHER_FUELLEN:
				f = np.array(bild)
				f[ndimage.binary_fill_holes(f[..., 3] > 128) & (f[..., 3] <= 128)] = (24, 16, 14, 255)
				bild = Image.fromarray(f)
			pfad = ZIEL / "objekte" / f"{name}.png"
			bild.save(pfad)
			if info.get("look"):
				look_pruefen.nachbearbeiten(pfad, "baukasten", pfad, None, regeln)
				bild = Image.open(pfad)
			flaeche, fuss = messen(bild)
			messung[name] = {"groesse": [bild.width, bild.height], "flaeche": flaeche, "fuss": fuss}
			print(f"{name:24s} {bild.width:4d} x {bild.height:4d}  Felder {flaeche}  Fuß {fuss}")
	datei.write_text(json.dumps(messung, ensure_ascii=False, indent="	"))


if __name__ == "__main__":
	main()
