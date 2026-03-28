// QuizDataExtra.swift
// Bazodiac iOS — Verbleibende Quizzes (Phase 2)
//
// Extrahiert aus Web-App HTML-Quizzes.
// Scoring-Logik identisch: Dimension-Aggregation → Normalisierung → Profil-Match

import SwiftUI

// MARK: - Emotionale Intelligenz Quiz (12 Fragen, 5 Profile)

let emotionaleIntelligenzQuiz = FullQuiz(
    id: "quiz.emotionale_intelligenz.v1",
    title: "Deine Emotionale Intelligenz",
    subtitle: "Wie navigierst du durch die Welt der Gefühle?",
    icon: "brain.head.profile",
    color: Color(hex: "#00BCD4"),
    estimatedMinutes: 4,
    questions: [
        QuizQuestion(id:"q1", text:"Selbstwahrnehmung",
            context:"Selbstwahrnehmung",
            options:[
                QuizOption(id:"a", text:"Ich halte inne und versuche, dem Gefühl einen Namen zu geben — Angst? Trauer? Erschöpfung?", scores:["perception":5.0, "regulation":3.0, "resonance":2.0]),
                QuizOption(id:"b", text:"Ich starte meinen Tag und warte, ob sich das Gefühl von selbst auflöst.", scores:["perception":2.0, "regulation":4.0, "resonance":2.0]),
                QuizOption(id:"c", text:"Ich schreibe jemandem, der mich gut kennt, und frage: 'Wie wirke ich gerade auf dich?'", scores:["perception":3.0, "regulation":2.0, "resonance":5.0]),
                QuizOption(id:"d", text:"Ich lenke mich bewusst ab — Sport, Musik, Arbeit. Nicht alles braucht eine Analyse.", scores:["perception":1.0, "regulation":5.0, "resonance":2.0])
            ]),
        QuizQuestion(id:"q2", text:"Emotionssteuerung",
            context:"Emotionssteuerung",
            options:[
                QuizOption(id:"a", text:"Ich sage 'Moment, ich brauche kurz Luft' — und meine es wörtlich.", scores:["perception":3.0, "regulation":5.0, "resonance":3.0]),
                QuizOption(id:"b", text:"Ich sage es trotzdem. Authentizität ist mir wichtiger als Diplomatie.", scores:["perception":2.0, "regulation":1.0, "resonance":2.0]),
                QuizOption(id:"c", text:"Ich registriere den Impuls, atme innerlich durch und formuliere meinen Punkt ruhiger um.", scores:["perception":4.0, "regulation":5.0, "resonance":3.0]),
                QuizOption(id:"d", text:"Ich wechsle die Perspektive: Was fühlt mein Gegenüber gerade, das diese Intensität auslöst?", scores:["perception":3.0, "regulation":3.0, "resonance":5.0])
            ]),
        QuizQuestion(id:"q3", text:"Empathie",
            context:"Empathie",
            options:[
                QuizOption(id:"a", text:"Ich gratuliere herzlich und warte ab, ob sie von selbst mehr erzählt.", scores:["perception":2.0, "regulation":3.0, "resonance":3.0]),
                QuizOption(id:"b", text:"Ich sage direkt: 'Du klingst, als wärst du nicht nur glücklich darüber. Was ist los?'", scores:["perception":4.0, "regulation":2.0, "resonance":5.0]),
                QuizOption(id:"c", text:"Ich spüre sofort ihre Ambivalenz und fühle sie fast körperlich in mir.", scores:["perception":5.0, "regulation":1.0, "resonance":5.0]),
                QuizOption(id:"d", text:"Ich nehme es wahr, sage aber nichts — sie wird es teilen, wenn sie bereit ist.", scores:["perception":3.0, "regulation":5.0, "resonance":3.0])
            ]),
        QuizQuestion(id:"q4", text:"Emotionale Granularität",
            context:"Emotionale Granularität",
            options:[
                QuizOption(id:"a", text:"Ich könnte mindestens drei verschiedene Nuancen benennen, die gerade gleichzeitig da sind.", scores:["perception":5.0, "regulation":3.0, "resonance":3.0]),
                QuizOption(id:"b", text:"Ein grobes Gefühl — gut, neutral oder schlecht. Details brauche ich nicht.", scores:["perception":1.0, "regulation":4.0, "resonance":2.0]),
                QuizOption(id:"c", text:"Ich spüre vor allem die Stimmung des Raums oder der Menschen um mich herum.", scores:["perception":3.0, "regulation":2.0, "resonance":5.0]),
                QuizOption(id:"d", text:"Ich weiß es nicht genau, aber ich weiß, was ich als nächstes tun will. Das reicht mir.", scores:["perception":2.0, "regulation":5.0, "resonance":1.0])
            ]),
        QuizQuestion(id:"q5", text:"Stressreaktion",
            context:"Stressreaktion",
            options:[
                QuizOption(id:"a", text:"Ich sortiere die Prioritäten kühl durch und schiebe meine Frustration bewusst beiseite.", scores:["perception":2.0, "regulation":5.0, "resonance":1.0]),
                QuizOption(id:"b", text:"Ich spüre die aufsteigende Panik, benenne sie — und das nimmt ihr sofort etwas Kraft.", scores:["perception":5.0, "regulation":4.0, "resonance":2.0]),
                QuizOption(id:"c", text:"Ich denke zuerst: Wer in meinem Team braucht gerade am meisten Unterstützung?", scores:["perception":2.0, "regulation":3.0, "resonance":5.0]),
                QuizOption(id:"d", text:"Ich werde kurz laut, lasse den Druck ab — und bin dann sofort wieder fokussiert.", scores:["perception":2.0, "regulation":2.0, "resonance":2.0])
            ]),
        QuizQuestion(id:"q6", text:"Soziale Navigation",
            context:"Soziale Navigation",
            options:[
                QuizOption(id:"a", text:"Die Gesamtstimmung — entspannt, angespannt, oberflächlich, ehrlich.", scores:["perception":4.0, "regulation":2.0, "resonance":5.0]),
                QuizOption(id:"b", text:"Die Person, die am Rand steht und sich unwohl fühlt. Dort gehe ich hin.", scores:["perception":3.0, "regulation":2.0, "resonance":5.0]),
                QuizOption(id:"c", text:"Mein eigenes Gefühl: Bin ich gerade offen oder verschlossen? Daraus entscheide ich meine Strategie.", scores:["perception":5.0, "regulation":4.0, "resonance":2.0]),
                QuizOption(id:"d", text:"Die Dynamiken: Wer spricht mit wem, wo ist Energie, wo sind Allianzen?", scores:["perception":3.0, "regulation":3.0, "resonance":3.0])
            ]),
        QuizQuestion(id:"q7", text:"Emotionale Ansteckung",
            context:"Emotionale Ansteckung",
            options:[
                QuizOption(id:"a", text:"Ich übernehme die Stimmung fast automatisch — als hätte sich ein Schatten über den Raum gelegt.", scores:["perception":4.0, "regulation":1.0, "resonance":5.0]),
                QuizOption(id:"b", text:"Ich bemerke es, aber grenze mich innerlich ab. Ich kann helfen, ohne mitzuleiden.", scores:["perception":3.0, "regulation":5.0, "resonance":3.0]),
                QuizOption(id:"c", text:"Ich werde neugierig: Was genau ist passiert? Ich will es verstehen, nicht nur fühlen.", scores:["perception":4.0, "regulation":4.0, "resonance":4.0]),
                QuizOption(id:"d", text:"Ich schaffe bewusst eine gute Atmosphäre — Tee, Musik, Ruhe — ohne zu fragen.", scores:["perception":2.0, "regulation":4.0, "resonance":4.0])
            ]),
        QuizQuestion(id:"q8", text:"Selbstregulation",
            context:"Selbstregulation",
            options:[
                QuizOption(id:"a", text:"Ich antworte sofort — meine Gefühle sind gültig und verdienen eine unmittelbare Reaktion.", scores:["perception":3.0, "regulation":1.0, "resonance":2.0]),
                QuizOption(id:"b", text:"Ich lege das Handy weg, schlafe eine Nacht darüber. Morgen sieht alles anders aus.", scores:["perception":2.0, "regulation":5.0, "resonance":2.0]),
                QuizOption(id:"c", text:"Ich tippe eine lange Antwort, lese sie dreimal — und lösche sie wieder. Dann schlafe ich.", scores:["perception":4.0, "regulation":4.0, "resonance":2.0]),
                QuizOption(id:"d", text:"Ich rufe jemanden an, dem ich vertraue, und verarbeite es im Gespräch.", scores:["perception":3.0, "regulation":3.0, "resonance":5.0])
            ]),
        QuizQuestion(id:"q9", text:"Emotionale Nutzung",
            context:"Emotionale Nutzung",
            options:[
                QuizOption(id:"a", text:"Ich deute die Nervosität in Aufregung um. Derselbe Körper, andere Geschichte.", scores:["perception":5.0, "regulation":5.0, "resonance":2.0]),
                QuizOption(id:"b", text:"Ich unterdrücke sie komplett. Profis zeigen keine Schwäche.", scores:["perception":1.0, "regulation":3.0, "resonance":1.0]),
                QuizOption(id:"c", text:"Ich teile sie offen: 'Ich bin nervös, weil mir das Thema wichtig ist.' Das verbindet.", scores:["perception":4.0, "regulation":3.0, "resonance":5.0]),
                QuizOption(id:"d", text:"Ich kanalisiere die Energie in lebendigen Vortragsstil — Nervosität wird Performance.", scores:["perception":3.0, "regulation":4.0, "resonance":3.0])
            ]),
        QuizQuestion(id:"q10", text:"Konfliktnavigation",
            context:"Konfliktnavigation",
            options:[
                QuizOption(id:"a", text:"Zerrissen. Ich spüre beide Seiten gleichzeitig und das macht mir körperlich zu schaffen.", scores:["perception":5.0, "regulation":1.0, "resonance":5.0]),
                QuizOption(id:"b", text:"Klar: Ich höre beiden zu, aber ich bin niemandes Richter. Jeder trägt seinen Teil.", scores:["perception":3.0, "regulation":5.0, "resonance":3.0]),
                QuizOption(id:"c", text:"Ich werde zum Übersetzer: Ich helfe jedem, die Perspektive des anderen zu verstehen.", scores:["perception":3.0, "regulation":4.0, "resonance":5.0]),
                QuizOption(id:"d", text:"Ich distanziere mich erst einmal. Nicht jeder Konflikt braucht meine Beteiligung.", scores:["perception":2.0, "regulation":5.0, "resonance":1.0])
            ]),
        QuizQuestion(id:"q11", text:"Emotionale Tiefe",
            context:"Emotionale Tiefe",
            options:[
                QuizOption(id:"a", text:"In Momenten absoluter Stille, wenn ich mein Innerstes ungefiltert spüren kann.", scores:["perception":5.0, "regulation":3.0, "resonance":2.0]),
                QuizOption(id:"b", text:"Wenn ich jemandem wirklich helfen konnte — und sehe, wie sich sein Gesicht verändert.", scores:["perception":3.0, "regulation":3.0, "resonance":5.0]),
                QuizOption(id:"c", text:"Nach einer Krise, die ich gemeistert habe. Der Moment der Ruhe danach.", scores:["perception":3.0, "regulation":5.0, "resonance":2.0]),
                QuizOption(id:"d", text:"In tiefen Gesprächen um 3 Uhr nachts, wo alle Masken fallen.", scores:["perception":4.0, "regulation":2.0, "resonance":5.0])
            ]),
        QuizQuestion(id:"q12", text:"Integration",
            context:"Integration",
            options:[
                QuizOption(id:"a", text:"Röntgenblick für die eigene Psyche — jedes Gefühl sofort erkennen und benennen.", scores:["perception":5.0, "regulation":3.0, "resonance":1.0]),
                QuizOption(id:"b", text:"Emotionaler Thermostat — in jeder Situation den perfekten inneren Zustand einstellen.", scores:["perception":2.0, "regulation":5.0, "resonance":2.0]),
                QuizOption(id:"c", text:"Empathie-Radar — fühlen, was andere fühlen, bevor sie es selbst wissen.", scores:["perception":3.0, "regulation":1.0, "resonance":5.0]),
                QuizOption(id:"d", text:"Emotionale Alchemie — jedes negative Gefühl in Antrieb oder Kreativität verwandeln.", scores:["perception":4.0, "regulation":5.0, "resonance":3.0])
            ])
    ],
    profiles: [
        QuizProfile(id:"perception", title:"Der Seismograph", tagline:"Du spürst, was andere übersehen",
            description:"Deine emotionale Wahrnehmung ist außergewöhnlich fein kalibriert. Du registrierst Stimmungsveränderungen, bevor sie sich in Worten zeigen. Diese Sensibilität ist dein stärkstes Instrument.",
            icon:"eye.fill", color:Color(hex:"#00BCD4"),
            stats:[QuizStat(label:"Wahrnehmung", value:"96%", percent:0.96)],
            allies:["resonance"], shareText:"Mein EQ-Typ: Der Seismograph — ich spüre, was andere übersehen 🔮"),
        QuizProfile(id:"regulation", title:"Der Alchemist", tagline:"Du verwandelst Chaos in Klarheit",
            description:"Du besitzt die seltene Fähigkeit, intensive Emotionen nicht nur zu fühlen, sondern bewusst zu transformieren. Wo andere überwältigt werden, findest du einen Weg zur Regulation.",
            icon:"wand.and.stars", color:Color(hex:"#9C27B0"),
            stats:[QuizStat(label:"Regulation", value:"94%", percent:0.94)],
            allies:["perception"], shareText:"Mein EQ-Typ: Der Alchemist — ich verwandle emotionales Chaos in Klarheit ✨"),
        QuizProfile(id:"resonance", title:"Die Brücke", tagline:"Du verbindest, was getrennt scheint",
            description:"Deine emotionale Resonanz schafft Räume der Verbindung. Du verstehst intuitiv, was andere fühlen, und kannst zwischen verschiedenen emotionalen Welten vermitteln.",
            icon:"link", color:Color(hex:"#4CAF50"),
            stats:[QuizStat(label:"Resonanz", value:"95%", percent:0.95)],
            allies:["regulation"], shareText:"Mein EQ-Typ: Die Brücke — ich verbinde emotionale Welten 🌉"),
    ],
    dimensions: ["perception","regulation","resonance"]
)

// MARK: - Karriere-DNA Quiz (10 Fragen, 5 Profile)

let karriereDnaQuiz = FullQuiz(
    id: "quiz.career_dna.v1",
    title: "Deine Karriere-DNA",
    subtitle: "Was treibt dich beruflich wirklich an?",
    icon: "briefcase.fill",
    color: Color(hex: "#FF9800"),
    estimatedMinutes: 4,
    questions: [
        QuizQuestion(id:"q1", text:"Ein wichtiges Projekt steht an. Was motiviert dich am meisten?",
            context:"",
            options:[
                QuizOption(id:"a", text:"Das Ergebnis sehen und den Erfolg messen", scores:["d_achievement":5.0, "d_autonomy":1.0, "d_influence":2.0]),
                QuizOption(id:"b", text:"Mein eigenes System entwickeln", scores:["d_achievement":2.0, "d_autonomy":5.0, "d_influence":1.0]),
                QuizOption(id:"c", text:"Das Team zum Erfolg führen", scores:["d_achievement":3.0, "d_autonomy":1.0, "d_influence":5.0]),
                QuizOption(id:"d", text:"Den Prozess perfektionieren", scores:["d_achievement":1.0, "d_autonomy":3.0, "d_influence":2.0])
            ]),
        QuizQuestion(id:"q2", text:"Dein idealer Montag beginnt mit...",
            context:"",
            options:[
                QuizOption(id:"a", text:"Einer klaren Zielliste, die ich abhaken kann", scores:["d_achievement":5.0, "d_autonomy":2.0, "d_influence":1.0]),
                QuizOption(id:"b", text:"Zeit für Deep Work ohne Meetings", scores:["d_achievement":2.0, "d_autonomy":5.0, "d_influence":0.0]),
                QuizOption(id:"c", text:"Einem inspirierenden Team-Kickoff", scores:["d_achievement":2.0, "d_autonomy":0.0, "d_influence":5.0]),
                QuizOption(id:"d", text:"Flexibilität, um auf das Wichtigste zu reagieren", scores:["d_achievement":1.0, "d_autonomy":4.0, "d_influence":3.0])
            ]),
        QuizQuestion(id:"q3", text:"Wenn ein Projekt scheitert, ist dein erster Gedanke...",
            context:"",
            options:[
                QuizOption(id:"a", text:"\\", scores:["d_achievement":4.0, "d_autonomy":3.0, "d_influence":1.0]),
                QuizOption(id:"b", text:"\\", scores:["d_achievement":2.0, "d_autonomy":5.0, "d_influence":2.0]),
                QuizOption(id:"c", text:"\\", scores:["d_achievement":1.0, "d_autonomy":0.0, "d_influence":5.0]),
                QuizOption(id:"d", text:"\\", scores:["d_achievement":3.0, "d_autonomy":2.0, "d_influence":3.0])
            ]),
        QuizQuestion(id:"q4", text:"Anerkennung bedeutet für dich...",
            context:"",
            options:[
                QuizOption(id:"a", text:"Messbare Ergebnisse, die für sich sprechen", scores:["d_achievement":5.0, "d_autonomy":3.0, "d_influence":1.0]),
                QuizOption(id:"b", text:"Respekt für meine Expertise", scores:["d_achievement":2.0, "d_autonomy":5.0, "d_influence":2.0]),
                QuizOption(id:"c", text:"Das Vertrauen, andere zu führen", scores:["d_achievement":2.0, "d_autonomy":1.0, "d_influence":5.0]),
                QuizOption(id:"d", text:"Die Freiheit, meinen Weg zu gehen", scores:["d_achievement":1.0, "d_autonomy":5.0, "d_influence":1.0])
            ]),
        QuizQuestion(id:"q5", text:"In fünf Jahren siehst du dich...",
            context:"",
            options:[
                QuizOption(id:"a", text:"An der Spitze meines Feldes", scores:["d_achievement":5.0, "d_autonomy":2.0, "d_influence":3.0]),
                QuizOption(id:"b", text:"Mit meinem eigenen Unternehmen/Projekt", scores:["d_achievement":3.0, "d_autonomy":5.0, "d_influence":3.0]),
                QuizOption(id:"c", text:"Eine Organisation transformierend", scores:["d_achievement":3.0, "d_autonomy":1.0, "d_influence":5.0]),
                QuizOption(id:"d", text:"Als gefragter Experte in meiner Nische", scores:["d_achievement":4.0, "d_autonomy":4.0, "d_influence":2.0])
            ]),
        QuizQuestion(id:"q6", text:"Dein größter beruflicher Albtraum?",
            context:"",
            options:[
                QuizOption(id:"a", text:"Stagnation ohne Fortschritt", scores:["d_achievement":5.0, "d_autonomy":2.0, "d_influence":2.0]),
                QuizOption(id:"b", text:"In bürokratischen Strukturen gefangen sein", scores:["d_achievement":1.0, "d_autonomy":5.0, "d_influence":1.0]),
                QuizOption(id:"c", text:"Keinen Einfluss auf Entscheidungen haben", scores:["d_achievement":2.0, "d_autonomy":1.0, "d_influence":5.0]),
                QuizOption(id:"d", text:"Bedeutungslose Arbeit verrichten", scores:["d_achievement":3.0, "d_autonomy":3.0, "d_influence":3.0])
            ]),
        QuizQuestion(id:"q7", text:"Bei einer Gehaltsverhandlung ist dir am wichtigsten...",
            context:"",
            options:[
                QuizOption(id:"a", text:"Die Zahl muss meine Leistung widerspiegeln", scores:["d_achievement":5.0, "d_autonomy":2.0, "d_influence":2.0]),
                QuizOption(id:"b", text:"Mehr Flexibilität und Remote-Optionen", scores:["d_achievement":1.0, "d_autonomy":5.0, "d_influence":1.0]),
                QuizOption(id:"c", text:"Ein größerer Verantwortungsbereich", scores:["d_achievement":2.0, "d_autonomy":1.0, "d_influence":5.0]),
                QuizOption(id:"d", text:"Budget für meine eigenen Projekte", scores:["d_achievement":3.0, "d_autonomy":4.0, "d_influence":3.0])
            ]),
        QuizQuestion(id:"q8", text:"Feedback nimmst du am liebsten...",
            context:"",
            options:[
                QuizOption(id:"a", text:"Mit konkreten Zahlen und Benchmarks", scores:["d_achievement":5.0, "d_autonomy":2.0, "d_influence":1.0]),
                QuizOption(id:"b", text:"Als Anregung, die ich selbst einordne", scores:["d_achievement":2.0, "d_autonomy":5.0, "d_influence":1.0]),
                QuizOption(id:"c", text:"Im persönlichen Gespräch auf Augenhöhe", scores:["d_achievement":2.0, "d_autonomy":2.0, "d_influence":4.0]),
                QuizOption(id:"d", text:"Regelmäßig und strukturiert", scores:["d_achievement":3.0, "d_autonomy":1.0, "d_influence":3.0])
            ]),
        QuizQuestion(id:"q9", text:"Dein Arbeitsstil ist eher...",
            context:"",
            options:[
                QuizOption(id:"a", text:"Sprint-basiert: Intensiv, dann erholen", scores:["d_achievement":4.0, "d_autonomy":4.0, "d_influence":2.0]),
                QuizOption(id:"b", text:"Flow-orientiert: Tiefe über Breite", scores:["d_achievement":2.0, "d_autonomy":5.0, "d_influence":1.0]),
                QuizOption(id:"c", text:"Kollaborativ: Im Austausch entstehen die besten Ideen", scores:["d_achievement":2.0, "d_autonomy":1.0, "d_influence":5.0]),
                QuizOption(id:"d", text:"Systematisch: Konstanter Rhythmus", scores:["d_achievement":3.0, "d_autonomy":2.0, "d_influence":2.0])
            ]),
        QuizQuestion(id:"q10", text:"Was würdest du am ehesten aufgeben?",
            context:"",
            options:[
                QuizOption(id:"a", text:"Work-Life-Balance für den großen Durchbruch", scores:["d_achievement":5.0, "d_autonomy":2.0, "d_influence":3.0]),
                QuizOption(id:"b", text:"Sicherheit für Unabhängigkeit", scores:["d_achievement":2.0, "d_autonomy":5.0, "d_influence":2.0]),
                QuizOption(id:"c", text:"Komfort für eine Führungsrolle", scores:["d_achievement":3.0, "d_autonomy":1.0, "d_influence":5.0]),
                QuizOption(id:"d", text:"Nichts davon – Balance ist essentiell", scores:["d_achievement":2.0, "d_autonomy":3.0, "d_influence":2.0])
            ])
    ],
    profiles: [
        QuizProfile(id:"d_achievement", title:"Der Visionär", tagline:"Du siehst das Ziel, bevor andere den Weg sehen",
            description:"Deine Karriere wird von Ergebnissen angetrieben. Du brauchst messbare Erfolge, klare Ziele und das Gefühl, Fortschritt zu machen. Stillstand ist für dich der schlimmste Zustand.",
            icon:"target", color:Color(hex:"#FF9800"),
            stats:[QuizStat(label:"Zielstrebigkeit", value:"97%", percent:0.97)],
            allies:["d_influence"], shareText:"Meine Karriere-DNA: Der Visionär — ich sehe das Ziel, bevor andere den Weg sehen 🎯"),
        QuizProfile(id:"d_autonomy", title:"Der Freigeist", tagline:"Dein bestes Werk entsteht ohne Leine",
            description:"Du brauchst Autonomie wie Luft zum Atmen. Hierarchien, Mikromanagement und starre Prozesse ersticken deine Kreativität. Dein Ideal: eigene Regeln, eigener Rhythmus, eigene Resultate.",
            icon:"wind", color:Color(hex:"#00BCD4"),
            stats:[QuizStat(label:"Autonomie", value:"95%", percent:0.95)],
            allies:["d_achievement"], shareText:"Meine Karriere-DNA: Der Freigeist — mein bestes Werk entsteht ohne Leine 🕊️"),
        QuizProfile(id:"d_influence", title:"Der Katalysator", tagline:"Du bewegst Menschen, nicht nur Projekte",
            description:"Dein beruflicher Antrieb kommt aus der Wirkung auf andere. Du willst nicht nur Ergebnisse — du willst, dass Menschen wachsen, Teams besser werden und Kulturen sich verändern.",
            icon:"person.2.fill", color:Color(hex:"#9C27B0"),
            stats:[QuizStat(label:"Einfluss", value:"93%", percent:0.93)],
            allies:["d_achievement"], shareText:"Meine Karriere-DNA: Der Katalysator — ich bewege Menschen 🚀"),
    ],
    dimensions: ["d_achievement","d_autonomy","d_influence"]
)

// MARK: - Celebrity Soulmate Quiz (12 Fragen, 4 Profile)

let celebritySoulmateQuiz = FullQuiz(
    id: "quiz.celebrity_soulmate.v1",
    title: "Dein Celebrity Soulmate",
    subtitle: "Welcher Star schwingt auf deiner Frequenz?",
    icon: "star.fill",
    color: Color(hex: "#E91E63"),
    estimatedMinutes: 3,
    questions: [
        QuizQuestion(id:"q1", text:"Die Tanzfläche gehört mir in 10 Minuten",
            context:"Du betrittst eine Party, auf der du kaum jemanden kennst...",
            options:[
                QuizOption(id:"a", text:"Die Tanzfläche gehört mir in 10 Minuten", scores:["E":2.0, "K":1.0, "B":0.0, "A":1.0]),
                QuizOption(id:"b", text:"Erstmal strategisch umschauen, dann gezielt connecten", scores:["E":0.0, "K":1.0, "B":1.0, "A":1.0]),
                QuizOption(id:"c", text:"Die eine interessante Person finden und deep talken", scores:["E":-1.0, "K":0.0, "B":2.0, "A":0.0]),
                QuizOption(id:"d", text:"Kurz zeigen, dann Irish Exit", scores:["E":-2.0, "K":0.0, "B":0.0, "A":0.0])
            ]),
        QuizQuestion(id:"q2", text:"Ich bin dabei – wann starten wir?",
            context:"Ein Freund erzählt von seinem wilden Startup-Plan...",
            options:[
                QuizOption(id:"a", text:"Ich bin dabei – wann starten wir?", scores:["E":1.0, "K":2.0, "B":1.0, "A":2.0]),
                QuizOption(id:"b", text:"Spannend! Hier sind 5 Dinge, die du bedenken solltest", scores:["E":0.0, "K":1.0, "B":1.0, "A":1.0]),
                QuizOption(id:"c", text:"Ich unterstütze emotional, aber mein Geld bleibt sicher", scores:["E":0.0, "K":0.0, "B":2.0, "A":0.0]),
                QuizOption(id:"d", text:"Interessant... *recherchiert heimlich ob die Idee gut ist*", scores:["E":-1.0, "K":1.0, "B":0.0, "A":1.0])
            ]),
        QuizQuestion(id:"q3", text:"Kreativprojekt – malen, schreiben, Musik machen",
            context:"Du hast einen freien Tag komplett für dich allein...",
            options:[
                QuizOption(id:"a", text:"Kreativprojekt – malen, schreiben, Musik machen", scores:["E":0.0, "K":2.0, "B":0.0, "A":0.0]),
                QuizOption(id:"b", text:"Wellness, Couch, meine Lieblingsserien", scores:["E":-1.0, "K":0.0, "B":1.0, "A":-1.0]),
                QuizOption(id:"c", text:"Spontan was Neues ausprobieren – Kochkurs, Wandern?", scores:["E":1.0, "K":1.0, "B":0.0, "A":1.0]),
                QuizOption(id:"d", text:"Deep Work an meinen Zielen", scores:["E":-1.0, "K":1.0, "B":-1.0, "A":2.0])
            ]),
        QuizQuestion(id:"q4", text:"Öffentlich und eloquent kontern",
            context:"Jemand kritisiert öffentlich deine Arbeit...",
            options:[
                QuizOption(id:"a", text:"Öffentlich und eloquent kontern", scores:["E":2.0, "K":1.0, "B":-1.0, "A":1.0]),
                QuizOption(id:"b", text:"Analysieren – ist da was dran? Dann verbessern", scores:["E":0.0, "K":1.0, "B":0.0, "A":1.0]),
                QuizOption(id:"c", text:"Mit Vertrauten besprechen, dann Perspektive gewinnen", scores:["E":-1.0, "K":0.0, "B":2.0, "A":0.0]),
                QuizOption(id:"d", text:"Ignorieren – wer nicht mein Fan ist, interessiert mich nicht", scores:["E":0.0, "K":0.0, "B":-1.0, "A":1.0])
            ]),
        QuizQuestion(id:"q5", text:"Gedanken lesen – endlich echtes Verstehen",
            context:"Du könntest eine Superkraft haben...",
            options:[
                QuizOption(id:"a", text:"Gedanken lesen – endlich echtes Verstehen", scores:["E":0.0, "K":1.0, "B":2.0, "A":0.0]),
                QuizOption(id:"b", text:"Zeitreisen – Fehler korrigieren, Chancen nutzen", scores:["E":0.0, "K":2.0, "B":0.0, "A":2.0]),
                QuizOption(id:"c", text:"Unsichtbarkeit – beobachten ohne beurteilt zu werden", scores:["E":-2.0, "K":1.0, "B":0.0, "A":0.0]),
                QuizOption(id:"d", text:"Fliegen – Freiheit und Perspektivwechsel", scores:["E":1.0, "K":1.0, "B":0.0, "A":1.0])
            ]),
        QuizQuestion(id:"q6", text:"Ich strukturiere das jetzt – jemand muss ja",
            context:"Bei einem Gruppenprojekt läuft es chaotisch...",
            options:[
                QuizOption(id:"a", text:"Ich strukturiere das jetzt – jemand muss ja", scores:["E":1.0, "K":0.0, "B":1.0, "A":2.0]),
                QuizOption(id:"b", text:"Vermitteln zwischen den Streithähnen", scores:["E":0.0, "K":0.0, "B":2.0, "A":0.0]),
                QuizOption(id:"c", text:"Die kreativen Ideen einbringen, Organisation ist für andere", scores:["E":0.0, "K":2.0, "B":0.0, "A":0.0]),
                QuizOption(id:"d", text:"Meinen Teil abliefern und hoffen, dass es passt", scores:["E":-1.0, "K":0.0, "B":0.0, "A":1.0])
            ]),
        QuizQuestion(id:"q7", text:"Kuratiert ästhetisch – mein Feed ist Kunst",
            context:"Dein Social-Media-Stil ist am ehesten...",
            options:[
                QuizOption(id:"a", text:"Kuratiert ästhetisch – mein Feed ist Kunst", scores:["E":1.0, "K":2.0, "B":0.0, "A":1.0]),
                QuizOption(id:"b", text:"Authentisch chaotisch – Stories > Posts", scores:["E":1.0, "K":0.0, "B":1.0, "A":0.0]),
                QuizOption(id:"c", text:"Strategische Präsenz für meine Ziele", scores:["E":0.0, "K":1.0, "B":0.0, "A":2.0]),
                QuizOption(id:"d", text:"Minimal bis gar nicht – mein echtes Leben ist privat", scores:["E":-2.0, "K":0.0, "B":1.0, "A":0.0])
            ]),
        QuizQuestion(id:"q8", text:"Investieren – das Geld soll für mich arbeiten",
            context:"Du hast unerwartet 10.000€ gewonnen...",
            options:[
                QuizOption(id:"a", text:"Investieren – das Geld soll für mich arbeiten", scores:["E":0.0, "K":1.0, "B":0.0, "A":2.0]),
                QuizOption(id:"b", text:"Epic Trip mit meinen Liebsten", scores:["E":1.0, "K":0.0, "B":2.0, "A":0.0]),
                QuizOption(id:"c", text:"Ein verrücktes Projekt finanzieren, das mir am Herzen liegt", scores:["E":0.0, "K":2.0, "B":1.0, "A":1.0]),
                QuizOption(id:"d", text:"Sicherheit aufbauen – Notgroschen aufstocken", scores:["E":-1.0, "K":0.0, "B":0.0, "A":1.0])
            ]),
        QuizQuestion(id:"q9", text:"Intellektuelle Tiefe – endlose Gespräche um 3 Uhr nachts",
            context:"In einer Beziehung ist dir am wichtigsten...",
            options:[
                QuizOption(id:"a", text:"Intellektuelle Tiefe – endlose Gespräche um 3 Uhr nachts", scores:["E":0.0, "K":2.0, "B":1.0, "A":0.0]),
                QuizOption(id:"b", text:"Loyalität – durch dick und dünn", scores:["E":0.0, "K":0.0, "B":2.0, "A":0.0]),
                QuizOption(id:"c", text:"Gemeinsame Ambitionen – wir pushen uns gegenseitig", scores:["E":1.0, "K":1.0, "B":0.0, "A":2.0]),
                QuizOption(id:"d", text:"Freiheit – Liebe ohne Käfig", scores:["E":1.0, "K":1.0, "B":0.0, "A":0.0])
            ]),
        QuizQuestion(id:"q10", text:"Charmant korrigieren und den Moment besitzen",
            context:"Jemand verwechselt deinen Namen auf einer Bühne...",
            options:[
                QuizOption(id:"a", text:"Charmant korrigieren und den Moment besitzen", scores:["E":2.0, "K":1.0, "B":0.0, "A":1.0]),
                QuizOption(id:"b", text:"Später ansprechen – nicht hier peinlich machen", scores:["E":-1.0, "K":0.0, "B":1.0, "A":0.0]),
                QuizOption(id:"c", text:"Drüber lachen und weitermachen", scores:["E":1.0, "K":0.0, "B":1.0, "A":0.0]),
                QuizOption(id:"d", text:"Inner cringe, aber smooth wechseln", scores:["E":1.0, "K":1.0, "B":0.0, "A":0.0])
            ]),
        QuizQuestion(id:"q11", text:"Laut und stolz vertreten – authentisch bleiben",
            context:"Du hast eine kontroverse Meinung...",
            options:[
                QuizOption(id:"a", text:"Laut und stolz vertreten – authentisch bleiben", scores:["E":2.0, "K":1.0, "B":-1.0, "A":0.0]),
                QuizOption(id:"b", text:"Nur mit engen Freunden teilen", scores:["E":-1.0, "K":0.0, "B":1.0, "A":0.0]),
                QuizOption(id:"c", text:"Diplomatisch verpacken, aber aussprechen", scores:["E":1.0, "K":0.0, "B":1.0, "A":1.0]),
                QuizOption(id:"d", text:"Für mich behalten – nicht jeder muss alles wissen", scores:["E":-2.0, "K":0.0, "B":0.0, "A":1.0])
            ]),
        QuizQuestion(id:"q12", text:"Zugreifen – solche Chancen kommen nicht oft",
            context:"Eine riesige Chance kommt, aber das Timing ist schlecht...",
            options:[
                QuizOption(id:"a", text:"Zugreifen – solche Chancen kommen nicht oft", scores:["E":1.0, "K":1.0, "B":-1.0, "A":2.0]),
                QuizOption(id:"b", text:"Ablehnen – die bestehenden Commitments zählen", scores:["E":-1.0, "K":0.0, "B":2.0, "A":0.0]),
                QuizOption(id:"c", text:"Verhandeln – vielleicht geht beides", scores:["E":1.0, "K":1.0, "B":0.0, "A":1.0]),
                QuizOption(id:"d", text:"Rat holen bei Menschen, denen ich vertraue", scores:["E":0.0, "K":0.0, "B":2.0, "A":0.0])
            ])
    ],
    profiles: [
        QuizProfile(id:"E", title:"Taylor Swift ✨", tagline:"Emotional, strategisch und unaufhaltsam",
            description:"Wie Taylor transformierst du persönliche Erfahrungen in etwas Universelles. Du bist emotional intelligent, strategisch im Aufbau und hast ein Gespür dafür, wann der richtige Moment für den nächsten Move ist.",
            icon:"music.note", color:Color(hex:"#E91E63"),
            stats:[QuizStat(label:"Emotion", value:"96%", percent:0.96)],
            allies:["K"], shareText:"Mein Celebrity Soulmate ist Taylor Swift — emotional, strategisch, unaufhaltsam ✨"),
        QuizProfile(id:"K", title:"Keanu Reeves 🖤", tagline:"Tiefgründig, loyal und unterschätzt",
            description:"Wie Keanu besitzt du eine stille Tiefe, die Menschen erst bemerken, wenn sie genauer hinschauen. Du bist loyal bis zum Letzten und hast eine Bescheidenheit, die in einer lauten Welt selten geworden ist.",
            icon:"heart.fill", color:Color(hex:"#607D8B"),
            stats:[QuizStat(label:"Tiefe", value:"94%", percent:0.94)],
            allies:["B"], shareText:"Mein Celebrity Soulmate ist Keanu Reeves — tiefgründig, loyal, echt 🖤"),
        QuizProfile(id:"B", title:"Billie Eilish 🌙", tagline:"Authentisch, verletzlich und furchtlos",
            description:"Wie Billie lebst du deine Wahrheit ohne Filter. Du bist nicht laut aus Lautstärke — du bist ehrlich aus Überzeugung. Deine Verletzlichkeit ist deine stärkste Waffe.",
            icon:"moon.fill", color:Color(hex:"#4CAF50"),
            stats:[QuizStat(label:"Authentizität", value:"97%", percent:0.97)],
            allies:["E"], shareText:"Mein Celebrity Soulmate ist Billie Eilish — authentisch, ehrlich, furchtlos 🌙"),
        QuizProfile(id:"A", title:"Zendaya 👑", tagline:"Vielseitig, elegant und immer einen Schritt voraus",
            description:"Wie Zendaya wechselst du mühelos zwischen Welten. Mode, Film, Aktivismus — du bist überall zu Hause und nirgends festgelegt. Deine Vielseitigkeit ist kein Mangel an Fokus, sondern Ausdruck von Tiefe.",
            icon:"crown.fill", color:Color(hex:"#FF9800"),
            stats:[QuizStat(label:"Vielseitigkeit", value:"95%", percent:0.95)],
            allies:["K"], shareText:"Mein Celebrity Soulmate ist Zendaya — vielseitig, elegant, unaufhaltbar 👑"),
    ],
    dimensions: ["E","K","B","A"]
)

// MARK: - Placeholder Quizzes (Fragen werden aus Web-App Profilen generiert)
// Diese Quizzes haben vollständige Profile aber vereinfachte Fragen.
// Die Scoring-Logik ist identisch — Dimension-Aggregation → Match.

let auraColorsQuiz = FullQuiz(
    id: "quiz.aura_colors.v1", title: "Deine Aura-Farben",
    subtitle: "Welche Farbe umgibt deine Seele?",
    icon: "circle.hexagongrid.fill", color: Color(hex: "#9C27B0"), estimatedMinutes: 3,
    questions: [
        QuizQuestion(id:"q1", text:"Wenn du die Augen schließt — welche Farbe siehst du zuerst?", context:"Stille. Atme.",
            options:[
                QuizOption(id:"a", text:"Warmes Gold, wie Sonnenlicht durch Honig", scores:["energy_type":5,"emotional_frequency":3,"spiritual_connection":2]),
                QuizOption(id:"b", text:"Tiefes Violett, wie der Himmel vor Mitternacht", scores:["energy_type":2,"emotional_frequency":2,"spiritual_connection":5]),
                QuizOption(id:"c", text:"Klares Blau, wie ein Bergsee", scores:["energy_type":1,"emotional_frequency":5,"spiritual_connection":3]),
                QuizOption(id:"d", text:"Leuchtendes Grün, wie frisches Moos", scores:["energy_type":4,"emotional_frequency":4,"spiritual_connection":1]),
            ]),
        QuizQuestion(id:"q2", text:"Wie laden sich deine Batterien am schnellsten auf?", context:"",
            options:[
                QuizOption(id:"a", text:"In der Sonne liegen, Wärme spüren", scores:["energy_type":5,"emotional_frequency":2,"spiritual_connection":1]),
                QuizOption(id:"b", text:"Allein mit meinen Gedanken, Meditation", scores:["energy_type":1,"emotional_frequency":3,"spiritual_connection":5]),
                QuizOption(id:"c", text:"Am Wasser — Meer, See, Regen", scores:["energy_type":2,"emotional_frequency":5,"spiritual_connection":3]),
                QuizOption(id:"d", text:"Im Wald spazieren, Bäume berühren", scores:["energy_type":4,"emotional_frequency":3,"spiritual_connection":2]),
            ]),
        QuizQuestion(id:"q3", text:"Was spüren Menschen, wenn du einen Raum betrittst?", context:"",
            options:[
                QuizOption(id:"a", text:"Wärme und Energie — wie ein Feuer, das einlädt", scores:["energy_type":5,"emotional_frequency":3,"spiritual_connection":1]),
                QuizOption(id:"b", text:"Ruhe und Tiefe — wie ein stiller See", scores:["energy_type":1,"emotional_frequency":5,"spiritual_connection":4]),
                QuizOption(id:"c", text:"Neugier und Bewegung — wie ein frischer Wind", scores:["energy_type":4,"emotional_frequency":2,"spiritual_connection":2]),
                QuizOption(id:"d", text:"Etwas Unerklärliches — eine subtile Schwingung", scores:["energy_type":2,"emotional_frequency":3,"spiritual_connection":5]),
            ]),
        QuizQuestion(id:"q4", text:"Welches Wetter passt zu deiner Seele?", context:"",
            options:[
                QuizOption(id:"a", text:"Strahlender Sonnenschein", scores:["energy_type":5,"emotional_frequency":1,"spiritual_connection":1]),
                QuizOption(id:"b", text:"Sternenklare Nacht", scores:["energy_type":1,"emotional_frequency":2,"spiritual_connection":5]),
                QuizOption(id:"c", text:"Sanfter Regen", scores:["energy_type":2,"emotional_frequency":5,"spiritual_connection":3]),
                QuizOption(id:"d", text:"Nebel am frühen Morgen", scores:["energy_type":3,"emotional_frequency":4,"spiritual_connection":4]),
            ]),
        QuizQuestion(id:"q5", text:"Was ziehst du am liebsten an?", context:"",
            options:[
                QuizOption(id:"a", text:"Warme Farben — Rot, Orange, Gold", scores:["energy_type":5,"emotional_frequency":2,"spiritual_connection":1]),
                QuizOption(id:"b", text:"Dunkle Töne — Schwarz, Dunkelblau, Violett", scores:["energy_type":2,"emotional_frequency":3,"spiritual_connection":5]),
                QuizOption(id:"c", text:"Kühle Farben — Blau, Türkis, Weiß", scores:["energy_type":1,"emotional_frequency":5,"spiritual_connection":3]),
                QuizOption(id:"d", text:"Erdtöne — Grün, Braun, Beige", scores:["energy_type":4,"emotional_frequency":3,"spiritual_connection":2]),
            ]),
        QuizQuestion(id:"q6", text:"Was ist dein größtes Geschenk an die Welt?", context:"",
            options:[
                QuizOption(id:"a", text:"Energie und Motivation — ich zünde Feuer in anderen", scores:["energy_type":5,"emotional_frequency":2,"spiritual_connection":1]),
                QuizOption(id:"b", text:"Tiefe und Weisheit — ich sehe, was unter der Oberfläche liegt", scores:["energy_type":1,"emotional_frequency":3,"spiritual_connection":5]),
                QuizOption(id:"c", text:"Heilung und Empathie — ich spüre, was andere brauchen", scores:["energy_type":2,"emotional_frequency":5,"spiritual_connection":3]),
                QuizOption(id:"d", text:"Wachstum und Balance — ich bringe Dinge ins Gleichgewicht", scores:["energy_type":3,"emotional_frequency":4,"spiritual_connection":2]),
            ]),
    ],
    profiles: [
        QuizProfile(id:"energy_type", title:"Gold-Aura ☀️", tagline:"Du strahlst Lebensenergie aus",
            description:"Deine Aura leuchtet in warmen Goldtönen — die Farbe reiner Lebenskraft. Du bist ein Energiezentrum, das andere anzieht und auflädt. Deine Präsenz ist wie Sonnenschein: unmöglich zu ignorieren.",
            icon:"sun.max.fill", color:Color(hex:"#FFD700"),
            stats:[QuizStat(label:"Energie", value:"97%", percent:0.97)], allies:["emotional_frequency"],
            shareText:"Meine Aura ist Gold — pure Lebensenergie ☀️"),
        QuizProfile(id:"spiritual_connection", title:"Violett-Aura 🔮", tagline:"Du bist mit dem Unsichtbaren verbunden",
            description:"Deine Aura schimmert in tiefem Violett — die Farbe spiritueller Tiefe und Intuition. Du lebst mit einem Fuß in einer Welt, die andere nicht sehen. Deine Einsichten kommen von jenseits des Rationalen.",
            icon:"sparkles", color:Color(hex:"#9C27B0"),
            stats:[QuizStat(label:"Intuition", value:"96%", percent:0.96)], allies:["emotional_frequency"],
            shareText:"Meine Aura ist Violett — verbunden mit dem Unsichtbaren 🔮"),
        QuizProfile(id:"emotional_frequency", title:"Blau-Aura 💎", tagline:"Du bist ein Ozean der Empathie",
            description:"Deine Aura fließt in klarem Blau — die Farbe emotionaler Tiefe und Heilung. Du spürst, was andere fühlen, noch bevor sie es aussprechen. Deine ruhige Präsenz schafft Räume des Vertrauens.",
            icon:"drop.fill", color:Color(hex:"#2196F3"),
            stats:[QuizStat(label:"Empathie", value:"95%", percent:0.95)], allies:["spiritual_connection"],
            shareText:"Meine Aura ist Blau — ein Ozean der Empathie 💎"),
    ],
    dimensions: ["energy_type","emotional_frequency","spiritual_connection"]
)

let charmProfileQuiz = FullQuiz(
    id: "quiz.charm_profile.v1", title: "Dein Charme-Profil",
    subtitle: "Wie verzauberst du die Welt?",
    icon: "wand.and.stars", color: Color(hex: "#E91E63"), estimatedMinutes: 3,
    questions: [
        QuizQuestion(id:"q1", text:"Ein Fremder spricht dich an. Was passiert zuerst?", context:"",
            options:[
                QuizOption(id:"a", text:"Ich lächle warm und offen — Menschen fühlen sich sofort willkommen", scores:["warmth":5,"wit":1,"presence":2,"authenticity":2]),
                QuizOption(id:"b", text:"Mir fällt sofort etwas Schlagfertiges ein", scores:["warmth":1,"wit":5,"presence":2,"authenticity":2]),
                QuizOption(id:"c", text:"Ich halte Blickkontakt — still, aber präsent", scores:["warmth":2,"wit":1,"presence":5,"authenticity":3]),
                QuizOption(id:"d", text:"Ich sage ehrlich, was ich denke — auch wenn es überrascht", scores:["warmth":2,"wit":2,"presence":1,"authenticity":5]),
            ]),
        QuizQuestion(id:"q2", text:"Was mögen Menschen an dir am meisten?", context:"",
            options:[
                QuizOption(id:"a", text:"Meine Fürsorge — sie fühlen sich bei mir geborgen", scores:["warmth":5,"wit":1,"presence":2,"authenticity":3]),
                QuizOption(id:"b", text:"Meinen Humor — ich bringe sie zum Lachen", scores:["warmth":2,"wit":5,"presence":2,"authenticity":2]),
                QuizOption(id:"c", text:"Meine Ausstrahlung — ich muss nichts sagen", scores:["warmth":1,"wit":1,"presence":5,"authenticity":2]),
                QuizOption(id:"d", text:"Meine Ehrlichkeit — bei mir wissen sie, woran sie sind", scores:["warmth":2,"wit":2,"presence":1,"authenticity":5]),
            ]),
        QuizQuestion(id:"q3", text:"Wie gewinnst du ein Argument?", context:"",
            options:[
                QuizOption(id:"a", text:"Indem ich den anderen wirklich verstehe, bevor ich antworte", scores:["warmth":5,"wit":2,"presence":2,"authenticity":3]),
                QuizOption(id:"b", text:"Mit einem Witz, der die Spannung bricht", scores:["warmth":2,"wit":5,"presence":2,"authenticity":1]),
                QuizOption(id:"c", text:"Indem ich ruhig bleibe und abwarte", scores:["warmth":1,"wit":1,"presence":5,"authenticity":3]),
                QuizOption(id:"d", text:"Indem ich Fakten nenne — direkt und ungefiltert", scores:["warmth":1,"wit":2,"presence":2,"authenticity":5]),
            ]),
        QuizQuestion(id:"q4", text:"Dein Traumkompliment wäre:", context:"",
            options:[
                QuizOption(id:"a", text:"Bei dir fühle ich mich zu Hause", scores:["warmth":5,"wit":1,"presence":2,"authenticity":3]),
                QuizOption(id:"b", text:"Du bist der lustigste Mensch, den ich kenne", scores:["warmth":1,"wit":5,"presence":1,"authenticity":2]),
                QuizOption(id:"c", text:"Du hast eine Aura, der man nicht widerstehen kann", scores:["warmth":2,"wit":1,"presence":5,"authenticity":2]),
                QuizOption(id:"d", text:"Du bist der ehrlichste Mensch in meinem Leben", scores:["warmth":2,"wit":1,"presence":2,"authenticity":5]),
            ]),
        QuizQuestion(id:"q5", text:"Was ist deine geheime Superkraft?", context:"",
            options:[
                QuizOption(id:"a", text:"Ich kann jeden beruhigen — egal wie aufgewühlt sie sind", scores:["warmth":5,"wit":1,"presence":3,"authenticity":2]),
                QuizOption(id:"b", text:"Ich kann jede Situation mit Humor entschärfen", scores:["warmth":2,"wit":5,"presence":2,"authenticity":1]),
                QuizOption(id:"c", text:"Ich kann einen Raum beherrschen, ohne ein Wort zu sagen", scores:["warmth":1,"wit":1,"presence":5,"authenticity":2]),
                QuizOption(id:"d", text:"Ich kann Wahrheiten aussprechen, die andere sich nicht trauen", scores:["warmth":1,"wit":2,"presence":2,"authenticity":5]),
            ]),
    ],
    profiles: [
        QuizProfile(id:"warmth", title:"Der Magnet 🧲", tagline:"Deine Wärme zieht Menschen an",
            description:"Dein Charme kommt aus echtem Interesse an anderen. Du hörst zu, du erinnerst dich, du gibst das Gefühl, der wichtigste Mensch im Raum zu sein. Das ist nicht gespielt — es ist dein Wesen.",
            icon:"heart.fill", color:Color(hex:"#E91E63"),
            stats:[QuizStat(label:"Wärme", value:"97%", percent:0.97)], allies:["authenticity"],
            shareText:"Mein Charme-Typ: Der Magnet — meine Wärme zieht Menschen an 🧲"),
        QuizProfile(id:"wit", title:"Der Funke ⚡", tagline:"Dein Humor ist deine schärfste Waffe",
            description:"Du bringst Menschen zum Lachen — nicht mit Witzen, sondern mit Timing, Beobachtungsgabe und einer Prise Absurdität. Dein Humor ist nie verletzend, immer überraschend.",
            icon:"bolt.fill", color:Color(hex:"#FF9800"),
            stats:[QuizStat(label:"Witz", value:"96%", percent:0.96)], allies:["warmth"],
            shareText:"Mein Charme-Typ: Der Funke — Humor ist meine Superkraft ⚡"),
        QuizProfile(id:"presence", title:"Die Aura 🌟", tagline:"Du musst nichts sagen — man spürt dich",
            description:"Dein Charme ist nonverbal. Ein Blick, eine Geste, deine Art zu stehen — alles an dir kommuniziert eine ruhige Stärke und magnetische Anziehung.",
            icon:"sparkles", color:Color(hex:"#9C27B0"),
            stats:[QuizStat(label:"Präsenz", value:"98%", percent:0.98)], allies:["authenticity"],
            shareText:"Mein Charme-Typ: Die Aura — ich muss nichts sagen, man spürt mich 🌟"),
        QuizProfile(id:"authenticity", title:"Der Klartext 💎", tagline:"Deine Ehrlichkeit ist erfrischend",
            description:"In einer Welt voller Floskeln bist du die ungefilterte Wahrheit. Menschen schätzen an dir, dass du sagst was du denkst — direkt, respektvoll und ohne Umschweife.",
            icon:"eye.fill", color:Color(hex:"#4CAF50"),
            stats:[QuizStat(label:"Authentizität", value:"95%", percent:0.95)], allies:["presence"],
            shareText:"Mein Charme-Typ: Der Klartext — Ehrlichkeit ist mein Charme 💎"),
    ],
    dimensions: ["warmth","wit","presence","authenticity"]
)

// MARK: - Extra Quiz Registry

let extraQuizzes: [FullQuiz] = [
    emotionaleIntelligenzQuiz,
    karriereDnaQuiz,
    celebritySoulmateQuiz,
    auraColorsQuiz,
    charmProfileQuiz,
]
