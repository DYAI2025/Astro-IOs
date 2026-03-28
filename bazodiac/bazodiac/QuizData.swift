// QuizData.swift
// Bazodiac iOS — Vollständige Quiz-Daten (1:1 Port von Web-App)
//
// Alle Fragen, Antworten und Scoring-Gewichte aus:
// /Bazodiac-WebApp/Astro-Noctum/features/plan/allquizzes/
//
// Scoring-Engine: dimension scores → normalisieren 0-100 → profil-matching
// Mapping-Logik identisch zur Web-App (quizzme-api-config.json)

import SwiftUI

// MARK: - Core Models

struct QuizQuestion: Identifiable {
    let id: String
    let text: String
    let context: String          // Szenario/Narrative über der Frage
    let options: [QuizOption]
}

struct QuizOption: Identifiable {
    let id: String
    let text: String
    let scores: [String: Double] // dimension → Punktwert
    var emoji: String = ""
}

struct QuizProfile: Identifiable {
    let id: String
    let title: String
    let tagline: String
    let description: String
    let icon: String             // SF Symbol oder Emoji
    let color: Color
    let stats: [QuizStat]
    let allies: [String]         // Kompatible Profile
    let shareText: String
}

struct QuizStat {
    let label: String
    let value: String
    let percent: Double          // 0.0 – 1.0
}

// MARK: - Quiz Definition

struct FullQuiz: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String             // SF Symbol
    let color: Color
    let estimatedMinutes: Int
    let questions: [QuizQuestion]
    let profiles: [QuizProfile]
    let dimensions: [String]
    /// Welche Dimension dominiert → Profil-Matching
    func matchProfile(scores: [String: Double]) -> QuizProfile? {
        guard !profiles.isEmpty else { return nil }
        // Dominant-Dimension bestimmen
        let dominantDim = scores.max(by: { $0.value < $1.value })?.key ?? ""
        // Profil mit passender condition finden
        return profiles.first { p in
            p.id.lowercased().contains(dominantDim.lowercased()) ||
            dominantDim.lowercased().contains(p.id.lowercased())
        } ?? profiles.first
    }
}

// MARK: - Liebessprachen-Quiz (12 Fragen, 5 Profile)

let loveLanguagesQuiz = FullQuiz(
    id: "quiz.love_languages.v1",
    title: "Welche Sprache spricht dein Herz?",
    subtitle: "Entdecke, wie du Liebe empfängst und gibst",
    icon: "heart.fill",
    color: Color(hex: "#C45C87"),
    estimatedMinutes: 3,
    questions: [
        QuizQuestion(id:"q1", text:"Was vermisst du nach einem Streit am meisten?",
            context:"Ihr hattet Streit. Jetzt liegt Stille zwischen euch wie frischer Schnee.",
            options:[
                QuizOption(id:"a", text:"Dass er oder sie ausspricht, was ich bedeute – dass die Worte die Stille durchbrechen", scores:["words":3,"time":1]),
                QuizOption(id:"b", text:"Einfach zusammen da zu sein – ohne dass jemand etwas sagen muss", scores:["time":3,"touch":1]),
                QuizOption(id:"c", text:"Eine kleine Geste, die zeigt: Ich denke an dich", scores:["gifts":3,"service":1]),
                QuizOption(id:"d", text:"Dass er oder sie etwas tut, um es wieder gut zu machen – Taten statt Worte", scores:["service":3,"words":1]),
                QuizOption(id:"e", text:"Eine Umarmung, die alles sagt, was Worte nicht können", scores:["touch":3,"time":1]),
            ]),
        QuizQuestion(id:"q2", text:"Deine ehrlichste Antwort: Was brauchst du gerade von mir?",
            context:"Dein Mensch fragt dich ehrlich: Was brauchst du gerade von mir?",
            options:[
                QuizOption(id:"a", text:"Sag mir, was du an mir siehst. Sag mir, dass das hier zählt.", scores:["words":3,"touch":1]),
                QuizOption(id:"b", text:"Sei einfach hier. Ganz hier. Nur wir beide.", scores:["time":3,"words":1]),
                QuizOption(id:"c", text:"Überrasch mich mit etwas, das zeigt, dass du an mich gedacht hast.", scores:["gifts":3,"time":1]),
                QuizOption(id:"d", text:"Nimm mir etwas ab. Zeig mir, dass wir ein Team sind.", scores:["service":3,"gifts":1]),
                QuizOption(id:"e", text:"Halt mich fest. Lass mich deine Wärme spüren.", scores:["touch":3,"service":1]),
            ]),
        QuizQuestion(id:"q3", text:"Wie zeigst du Liebe am natürlichsten?",
            context:"Es ist spät. Dein Mensch hatte einen schweren Tag.",
            options:[
                QuizOption(id:"a", text:"Ich sage die Worte, die niemand sonst findet", scores:["words":3,"time":1]),
                QuizOption(id:"b", text:"Ich bin einfach da – präsent, aufmerksam, ganz bei ihm", scores:["time":3,"touch":1]),
                QuizOption(id:"c", text:"Ich besorge etwas Kleines, das sagt: Du bist mir wichtig", scores:["gifts":3,"service":1]),
                QuizOption(id:"d", text:"Ich räume auf, koche, nehme ihm etwas ab", scores:["service":3,"words":1]),
                QuizOption(id:"e", text:"Ich halte ihn still – meine Arme sagen alles", scores:["touch":3,"service":1]),
            ]),
        QuizQuestion(id:"q4", text:"Was bedeutet Intimität für dich wirklich?",
            context:"Du denkst an eure schönsten gemeinsamen Momente.",
            options:[
                QuizOption(id:"a", text:"Tiefe Gespräche, in denen wir uns wirklich sehen", scores:["words":3,"time":1]),
                QuizOption(id:"b", text:"Schweigend nebeneinander – und es fühlt sich wie Zuhause an", scores:["time":3,"touch":1]),
                QuizOption(id:"c", text:"Das kleine Geschenk ohne Anlass, das zeigt: Du denkst an mich", scores:["gifts":3,"words":1]),
                QuizOption(id:"d", text:"Wenn er oder sie ohne Worte weiß, was ich brauche – und es tut", scores:["service":3,"time":1]),
                QuizOption(id:"e", text:"Körperliche Nähe – halten, berühren, verbunden sein", scores:["touch":3,"gifts":1]),
            ]),
        QuizQuestion(id:"q5", text:"Was verletzt dich am meisten?",
            context:"Dein Mensch hat etwas getan, das dich tief verletzt.",
            options:[
                QuizOption(id:"a", text:"Wenn er oder sie nichts sagt – Schweigen, wo Worte sein sollten", scores:["words":3,"time":1]),
                QuizOption(id:"b", text:"Wenn er oder sie abgelenkt ist – körperlich hier, aber gedanklich weit weg", scores:["time":3,"words":1]),
                QuizOption(id:"c", text:"Wenn er oder sie vergisst, was mir wichtig ist – kein Zeichen des Gedenkens", scores:["gifts":3,"service":1]),
                QuizOption(id:"d", text:"Wenn Versprechen gebrochen werden – Worte ohne Taten", scores:["service":3,"touch":1]),
                QuizOption(id:"e", text:"Wenn Distanz zwischen uns tritt – keine Berührung, keine Nähe", scores:["touch":3,"time":1]),
            ]),
        QuizQuestion(id:"q6", text:"Wie schenkst du Trost?",
            context:"Ein guter Freund weint. Du weißt nicht warum.",
            options:[
                QuizOption(id:"a", text:"Ich finde die richtigen Worte – sage, was er hören muss", scores:["words":3,"time":1]),
                QuizOption(id:"b", text:"Ich setze mich einfach neben ihn. Still. Wartend.", scores:["time":3,"touch":1]),
                QuizOption(id:"c", text:"Ich bringe etwas mit – etwas, das zeigt: Du bist nicht allein", scores:["gifts":3,"service":1]),
                QuizOption(id:"d", text:"Ich tue, was getan werden muss – Tee, Aufräumen, Ablenkung schaffen", scores:["service":3,"words":1]),
                QuizOption(id:"e", text:"Ich umarme ihn einfach. Lange. Ohne Worte.", scores:["touch":3,"gifts":1]),
            ]),
        QuizQuestion(id:"q7", text:"Wie feiern wir zusammen?",
            context:"Ihr feiert heute euren Jahrestag.",
            options:[
                QuizOption(id:"a", text:"Mit einem Brief, in dem ich alles aufschreibe, was er mir bedeutet", scores:["words":3,"gifts":1]),
                QuizOption(id:"b", text:"Mit einem Tag, ganz für uns – kein Handy, kein Rest der Welt", scores:["time":3,"words":1]),
                QuizOption(id:"c", text:"Mit einem Geschenk, das ich seit Monaten plane", scores:["gifts":3,"service":1]),
                QuizOption(id:"d", text:"Indem ich alles organisiere – kein Stress für ihn, alles perfekt", scores:["service":3,"time":1]),
                QuizOption(id:"e", text:"Mit Nähe – tanzen, halten, fühlen, dass wir da sind", scores:["touch":3,"time":1]),
            ]),
        QuizQuestion(id:"q8", text:"Was magst du besonders an unseren Routinen?",
            context:"Jeden Morgen gibt es diesen kleinen Moment.",
            options:[
                QuizOption(id:"a", text:"Das Guten-Morgen-Sagen – diese kurzen Worte, die alles bedeuten", scores:["words":3,"touch":1]),
                QuizOption(id:"b", text:"Der gemeinsame Kaffee – still, präsent, ohne Hast", scores:["time":3,"words":1]),
                QuizOption(id:"c", text:"Wenn er oder sie mir manchmal einfach etwas mitbringt", scores:["gifts":3,"time":1]),
                QuizOption(id:"d", text:"Wenn er oder sie schon weiß, was ich brauche – und es einfach tut", scores:["service":3,"words":1]),
                QuizOption(id:"e", text:"Das Aneinanderschmiegen – diese Stille, die verbindet", scores:["touch":3,"service":1]),
            ]),
        QuizQuestion(id:"q9", text:"Wie merkst du, dass er oder sie dich liebt?",
            context:"Manchmal weißt du es einfach – ohne Worte.",
            options:[
                QuizOption(id:"a", text:"Wenn er oder sie mir sagt, was ich bedeute – konkret und ehrlich", scores:["words":3,"time":1]),
                QuizOption(id:"b", text:"Wenn er oder sie sein Handy weglegt und wirklich zuhört", scores:["time":3,"words":1]),
                QuizOption(id:"c", text:"Wenn er oder sie an mich denkt – ein Foto, eine Notiz, eine Kleinigkeit", scores:["gifts":3,"service":1]),
                QuizOption(id:"d", text:"Wenn er oder sie handelt – ohne dass ich fragen muss", scores:["service":3,"touch":1]),
                QuizOption(id:"e", text:"Wenn er oder sie mich berührt – eine Hand, eine Umarmung, Nähe", scores:["touch":3,"time":1]),
            ]),
        QuizQuestion(id:"q10", text:"Was macht ein Geschenk bedeutsam?",
            context:"Du hast ein Geschenk erhalten.",
            options:[
                QuizOption(id:"a", text:"Die Worte dazu – was er oder sie dabei gedacht hat", scores:["words":3,"gifts":1]),
                QuizOption(id:"b", text:"Die Zeit, die dahintersteckt – gemeinsam etwas erlebt", scores:["time":3,"words":1]),
                QuizOption(id:"c", text:"Dass es zeigt: Er oder sie kennt mich wirklich", scores:["gifts":3,"service":1]),
                QuizOption(id:"d", text:"Dass es etwas abnimmt – Stress, Arbeit, Verantwortung", scores:["service":3,"time":1]),
                QuizOption(id:"e", text:"Die Geste dahinter – die Berührung, wenn es übergeben wird", scores:["touch":3,"gifts":1]),
            ]),
        QuizQuestion(id:"q11", text:"Wie fühlst du dich nach einem guten Gespräch?",
            context:"Ihr habt zwei Stunden lang geredet – wirklich geredet.",
            options:[
                QuizOption(id:"a", text:"Aufgetankt. Worte sind meine Nahrung.", scores:["words":3,"time":1]),
                QuizOption(id:"b", text:"Verbunden. Als ob wir die Zeit vergessen haben.", scores:["time":3,"words":1]),
                QuizOption(id:"c", text:"Inspiriert, ihm oder ihr etwas zu schenken – als Erinnerung", scores:["gifts":3,"touch":1]),
                QuizOption(id:"d", text:"Motiviert, etwas für ihn oder sie zu tun", scores:["service":3,"time":1]),
                QuizOption(id:"e", text:"Berührt – im wörtlichen Sinne. Ich brauche jetzt Nähe.", scores:["touch":3,"service":1]),
            ]),
        QuizQuestion(id:"q12", text:"Was bedeutet Zuhause für dich?",
            context:"Du schließt die Augen und stellst dir Heimat vor.",
            options:[
                QuizOption(id:"a", text:"Ein Ort, wo Worte ehrlich sind und gehört werden", scores:["words":3,"time":1]),
                QuizOption(id:"b", text:"Wo jemand einfach da ist – ganz da", scores:["time":3,"touch":1]),
                QuizOption(id:"c", text:"Wo kleine Zeichen sagen: Du wirst nicht vergessen", scores:["gifts":3,"words":1]),
                QuizOption(id:"d", text:"Wo jemand handelt, ohne dass ich bitte", scores:["service":3,"time":1]),
                QuizOption(id:"e", text:"Wo ich ankomme und umarmt werde – immer", scores:["touch":3,"service":1]),
            ]),
    ],
    profiles: [
        QuizProfile(id:"words", title:"Der Wortschmied", tagline:"Deine Liebe lebt in der Sprache",
            description:"Du liebst durch Worte – ehrlich, direkt und von Herzen. Ein aufrichtig gesagtes »Ich liebe dich« bedeutet dir mehr als jede Tat. Du blühst auf, wenn dein Partner deine Qualitäten benennt und dich mit Worten bestärkt. Schweigen fühlt sich für dich oft wie Distanz an.",
            icon:"bubble.left.fill", color:Color(hex:"#C45C87"),
            stats:[QuizStat(label:"Verbal", value:"95%", percent:0.95), QuizStat(label:"Emotional", value:"88%", percent:0.88)],
            allies:["time","touch"], shareText:"Meine Liebessprache ist »Worte der Bestätigung« – Ich liebe durch Sprache 💬"),
        QuizProfile(id:"time", title:"Der Präsenzwächter", tagline:"Ungeteilte Aufmerksamkeit ist dein Geschenk",
            description:"Für dich ist Qualitätszeit das höchste Gut der Liebe. Du sehnst dich nicht nach Worten oder Geschenken – du sehnst dich nach echter Präsenz. Wenn jemand sein Handy weglegt und wirklich bei dir ist, fühlt sich das wie Liebe an.",
            icon:"clock.fill", color:Color(hex:"#4A85C4"),
            stats:[QuizStat(label:"Präsenz", value:"97%", percent:0.97), QuizStat(label:"Tiefe", value:"91%", percent:0.91)],
            allies:["words","touch"], shareText:"Meine Liebessprache ist »Qualitätszeit« – Ich brauche echte Präsenz ⏳"),
        QuizProfile(id:"gifts", title:"Der Symbolträger", tagline:"Kleine Gesten erzählen große Geschichten",
            description:"Für dich sind Geschenke sichtbare Beweise der Liebe – nicht aus Materialismus, sondern aus dem tiefen Wunsch, gesehen und erinnert zu werden. Ein kleines Mitbringsel ohne Anlass sagt mehr als tausend Worte.",
            icon:"gift.fill", color:Color(hex:"#9B59B6"),
            stats:[QuizStat(label:"Symbolik", value:"92%", percent:0.92), QuizStat(label:"Fürsorge", value:"85%", percent:0.85)],
            allies:["service","words"], shareText:"Meine Liebessprache ist »Geschenke« – Ich liebe durch sichtbare Zeichen 🎁"),
        QuizProfile(id:"service", title:"Der stille Beweger", tagline:"Liebe zeigt sich in Taten, nicht in Worten",
            description:"Du glaubst, dass echte Liebe sich in Handlungen ausdrückt. Wenn jemand für dich kocht, Dinge organisiert oder einfach handelt, ohne gefragt zu werden – das ist für dich der reinste Ausdruck von Fürsorge.",
            icon:"hands.sparkles.fill", color:Color(hex:"#52A853"),
            stats:[QuizStat(label:"Praktisch", value:"94%", percent:0.94), QuizStat(label:"Verlässlich", value:"89%", percent:0.89)],
            allies:["time","touch"], shareText:"Meine Liebessprache ist »Hilfsbereitschaft« – Ich zeige Liebe durch Taten 🤝"),
        QuizProfile(id:"touch", title:"Der Nähesucher", tagline:"Berührung ist deine Muttersprache",
            description:"Für dich ist körperliche Nähe das unmittelbarste Zeichen von Liebe. Eine Hand auf deiner, eine Umarmung, das Aneinanderschmiegen auf dem Sofa – das sind die Momente, in denen du dich wirklich geliebt fühlst.",
            icon:"heart.circle.fill", color:Color(hex:"#E74C3C"),
            stats:[QuizStat(label:"Körpernähe", value:"96%", percent:0.96), QuizStat(label:"Verbindung", value:"93%", percent:0.93)],
            allies:["time","service"], shareText:"Meine Liebessprache ist »Körperliche Berührung« – Nähe ist alles für mich 🤗"),
    ],
    dimensions: ["words","time","gifts","service","touch"]
)

// MARK: - Krafttier-Quiz (12 Fragen, 8 Profile)

let krafttierQuiz = FullQuiz(
    id: "quiz.spirit_animal.v1",
    title: "Dein Krafttier",
    subtitle: "Welches Tier trägt deine Seele?",
    icon: "leaf.fill",
    color: Color(hex: "#52A853"),
    estimatedMinutes: 4,
    questions: [
        QuizQuestion(id:"q1", text:"Du stehst vor einem unbekannten Pfad im Wald. Wie reagierst du?",
            context:"Der Nebel lichtet sich...",
            options:[
                QuizOption(id:"a", text:"Ich gehe voran – Neuland ruft nach mir", scores:["mut":5,"instinkt":3,"freiheit":4]),
                QuizOption(id:"b", text:"Ich beobachte erst, lese die Zeichen", scores:["weisheit":5,"klarheit":4,"vorsicht":3]),
                QuizOption(id:"c", text:"Ich suche Begleitung für die Reise", scores:["sozial":5,"erdung":3,"anpassung":2]),
                QuizOption(id:"d", text:"Ich finde meinen eigenen Weg abseits des Pfades", scores:["instinkt":5,"freiheit":4,"mut":2]),
            ]),
        QuizQuestion(id:"q2", text:"Welche Energie zieht dich am meisten an?",
            context:"Du spürst eine Kraft in dir aufsteigen.",
            options:[
                QuizOption(id:"a", text:"Die Kraft des Feuers – intensiv, transformierend", scores:["mut":5,"instinkt":4,"freiheit":3]),
                QuizOption(id:"b", text:"Die Tiefe des Wassers – ruhig, unergründlich", scores:["weisheit":5,"vorsicht":3,"klarheit":4]),
                QuizOption(id:"c", text:"Die Verbundenheit der Erde – beständig, nährend", scores:["erdung":5,"sozial":4,"anpassung":3]),
                QuizOption(id:"d", text:"Die Freiheit des Windes – leicht, überall und nirgends", scores:["freiheit":5,"instinkt":3,"anpassung":4]),
            ]),
        QuizQuestion(id:"q3", text:"Wie gehst du mit Herausforderungen um?",
            context:"Eine große Aufgabe liegt vor dir.",
            options:[
                QuizOption(id:"a", text:"Ich stürme direkt hinein – Kraft und Entschlossenheit", scores:["mut":5,"instinkt":4,"freiheit":3]),
                QuizOption(id:"b", text:"Ich analysiere erst alles gründlich", scores:["klarheit":5,"weisheit":4,"vorsicht":3]),
                QuizOption(id:"c", text:"Ich hole mir Rat und Unterstützung", scores:["sozial":5,"erdung":3,"anpassung":4]),
                QuizOption(id:"d", text:"Ich warte auf den richtigen Moment", scores:["weisheit":4,"vorsicht":5,"klarheit":3]),
            ]),
        QuizQuestion(id:"q4", text:"Was ist deine größte Stärke?",
            context:"Andere Menschen schätzen an dir besonders...",
            options:[
                QuizOption(id:"a", text:"Meine Entschlossenheit – ich gebe nie auf", scores:["mut":5,"instinkt":4,"freiheit":2]),
                QuizOption(id:"b", text:"Meine Weisheit – ich sehe, was andere übersehen", scores:["weisheit":5,"klarheit":4,"vorsicht":3]),
                QuizOption(id:"c", text:"Mein Herz – ich verbinde und heile", scores:["sozial":5,"erdung":4,"anpassung":3]),
                QuizOption(id:"d", text:"Meine Anpassungsfähigkeit – ich finde immer einen Weg", scores:["anpassung":5,"freiheit":4,"instinkt":3]),
            ]),
        QuizQuestion(id:"q5", text:"Wie lebst du deine Freiheit?",
            context:"Ein freier Tag liegt vor dir.",
            options:[
                QuizOption(id:"a", text:"Ich explore Neues – allein, ohne Plan", scores:["freiheit":5,"mut":4,"instinkt":3]),
                QuizOption(id:"b", text:"Ich ziehe mich zurück – Stille und Beobachtung", scores:["weisheit":5,"vorsicht":4,"klarheit":3]),
                QuizOption(id:"c", text:"Ich verbringe Zeit mit Menschen, die mir wichtig sind", scores:["sozial":5,"erdung":4,"anpassung":2]),
                QuizOption(id:"d", text:"Ich folge meinem Instinkt – wohin auch immer er führt", scores:["instinkt":5,"freiheit":4,"mut":3]),
            ]),
        QuizQuestion(id:"q6", text:"Wie reagierst du auf Gefahr?",
            context:"Eine bedrohliche Situation entsteht.",
            options:[
                QuizOption(id:"a", text:"Ich stelle mich ihr direkt entgegen", scores:["mut":5,"instinkt":3,"freiheit":2]),
                QuizOption(id:"b", text:"Ich berechne schnell den besten Ausweg", scores:["klarheit":5,"weisheit":4,"vorsicht":3]),
                QuizOption(id:"c", text:"Ich schütze die, die bei mir sind", scores:["sozial":5,"erdung":4,"mut":3]),
                QuizOption(id:"d", text:"Ich weiche geschickt aus – Schlauheit schlägt Kraft", scores:["anpassung":5,"vorsicht":4,"weisheit":3]),
            ]),
        QuizQuestion(id:"q7", text:"Was ist dein tiefstes Verlangen?",
            context:"Wenn du ganz ehrlich bist zu dir selbst...",
            options:[
                QuizOption(id:"a", text:"Grenzen zu überschreiten und mich zu beweisen", scores:["mut":5,"freiheit":4,"instinkt":3]),
                QuizOption(id:"b", text:"Die Wahrheit zu verstehen – die tiefste Wahrheit", scores:["weisheit":5,"klarheit":5,"vorsicht":2]),
                QuizOption(id:"c", text:"Tief verbunden zu sein – mit Menschen, mit der Welt", scores:["sozial":5,"erdung":5,"anpassung":2]),
                QuizOption(id:"d", text:"Frei zu sein – von allem, was mich einengt", scores:["freiheit":5,"instinkt":4,"mut":3]),
            ]),
        QuizQuestion(id:"q8", text:"Wie triffst du wichtige Entscheidungen?",
            context:"Eine Weggabelung liegt vor dir.",
            options:[
                QuizOption(id:"a", text:"Aus dem Bauch heraus – mein Instinkt weiß es", scores:["instinkt":5,"mut":4,"freiheit":3]),
                QuizOption(id:"b", text:"Nach gründlichem Abwägen aller Faktoren", scores:["klarheit":5,"weisheit":4,"vorsicht":4]),
                QuizOption(id:"c", text:"Ich hole mir Rat bei Menschen, denen ich vertraue", scores:["sozial":5,"erdung":3,"anpassung":3]),
                QuizOption(id:"d", text:"Ich warte, bis sich der richtige Weg zeigt", scores:["weisheit":4,"vorsicht":5,"klarheit":3]),
            ]),
        QuizQuestion(id:"q9", text:"Was siehst du, wenn du in den Spiegel schaust?",
            context:"Ein ehrlicher Blick auf dich selbst.",
            options:[
                QuizOption(id:"a", text:"Einen Kämpfer – stark und unerschütterlich", scores:["mut":5,"instinkt":4,"freiheit":3]),
                QuizOption(id:"b", text:"Einen Denker – weise und beobachtend", scores:["weisheit":5,"klarheit":5,"vorsicht":3]),
                QuizOption(id:"c", text:"Ein Wesen der Verbindung – warm und offen", scores:["sozial":5,"erdung":4,"anpassung":3]),
                QuizOption(id:"d", text:"Einen Wandler – anpassungsfähig und ungreifbar", scores:["anpassung":5,"freiheit":4,"instinkt":3]),
            ]),
        QuizQuestion(id:"q10", text:"Wie gehst du mit Einsamkeit um?",
            context:"Du bist für eine Zeit allein.",
            options:[
                QuizOption(id:"a", text:"Ich nutze sie für Abenteuer und Exploration", scores:["freiheit":5,"mut":4,"instinkt":3]),
                QuizOption(id:"b", text:"Ich genieße die Stille zum Nachdenken", scores:["weisheit":5,"klarheit":4,"vorsicht":3]),
                QuizOption(id:"c", text:"Ich suche bald wieder Kontakt – ich brauche Menschen", scores:["sozial":5,"erdung":4,"anpassung":2]),
                QuizOption(id:"d", text:"Ich folge jedem Impuls, der in mir aufsteigt", scores:["instinkt":5,"freiheit":4,"mut":3]),
            ]),
        QuizQuestion(id:"q11", text:"Welches Tier ruft in dir eine tiefe Resonanz?",
            context:"Schließe die Augen. Welches Tier erscheint?",
            options:[
                QuizOption(id:"a", text:"Der Adler – majestätisch, frei, mit Weitblick", scores:["freiheit":5,"weisheit":4,"mut":3]),
                QuizOption(id:"b", text:"Der Wolf – weise, loyal, des Rudels Hüter", scores:["sozial":5,"instinkt":4,"mut":3]),
                QuizOption(id:"c", text:"Der Fuchs – clever, anpassungsfähig, immer einen Schritt voraus", scores:["anpassung":5,"klarheit":4,"freiheit":3]),
                QuizOption(id:"d", text:"Der Bär – stark, geerdet, schützend", scores:["erdung":5,"mut":4,"sozial":3]),
            ]),
        QuizQuestion(id:"q12", text:"Was hinterlässt du in der Welt?",
            context:"Wie sollen Menschen an dich denken?",
            options:[
                QuizOption(id:"a", text:"Als jemanden, der mutig voranging wo andere zögerten", scores:["mut":5,"freiheit":4,"instinkt":3]),
                QuizOption(id:"b", text:"Als jemanden, der tiefe Einsichten schenkte", scores:["weisheit":5,"klarheit":4,"vorsicht":2]),
                QuizOption(id:"c", text:"Als jemanden, der echte Verbindungen schuf", scores:["sozial":5,"erdung":4,"anpassung":3]),
                QuizOption(id:"d", text:"Als jemanden, der sich nie hat einsperren lassen", scores:["freiheit":5,"instinkt":4,"anpassung":3]),
            ]),
    ],
    profiles: [
        QuizProfile(id:"mut", title:"Der Löwe 🦁", tagline:"König des Mutes und der Entschlossenheit",
            description:"Du trägst den Geist des Löwen in dir – majestätisch, furchtlos und führend. Deine Entschlossenheit ist ansteckend, dein Mut inspirierend. Du gehst voran, wenn andere zögern, und trägst andere mit deiner Kraft.",
            icon:"flame.fill", color:Color(hex:"#E74C3C"),
            stats:[QuizStat(label:"Mut", value:"97%", percent:0.97), QuizStat(label:"Führung", value:"92%", percent:0.92)],
            allies:["instinkt","freiheit"], shareText:"Mein Krafttier ist der Löwe – furchtlos, führend und voller Feuer 🦁"),
        QuizProfile(id:"weisheit", title:"Die Eule 🦉", tagline:"Hüterin des Wissens und der Intuition",
            description:"Die Eule sieht in der Dunkelheit, was andere nicht erkennen. Du besitzt eine tiefe Weisheit und die Fähigkeit, unter die Oberfläche zu blicken. Deine Beobachtungsgabe ist dein größtes Geschenk.",
            icon:"eye.fill", color:Color(hex:"#9B59B6"),
            stats:[QuizStat(label:"Weisheit", value:"95%", percent:0.95), QuizStat(label:"Intuition", value:"89%", percent:0.89)],
            allies:["klarheit","vorsicht"], shareText:"Mein Krafttier ist die Eule – weise, tiefblickend, ein Hüter des Wissens 🦉"),
        QuizProfile(id:"sozial", title:"Der Wolf 🐺", tagline:"Seele des Rudels, Wächter der Verbindung",
            description:"Der Wolf ist klug, loyal und lebt in tiefer Verbindung. Du brauchst echte Zugehörigkeit – nicht Masse, sondern echte Verbundenheit. Deine Loyalität ist dein stärkstes Merkmal.",
            icon:"person.2.fill", color:Color(hex:"#4A85C4"),
            stats:[QuizStat(label:"Loyalität", value:"96%", percent:0.96), QuizStat(label:"Verbindung", value:"91%", percent:0.91)],
            allies:["erdung","sozial"], shareText:"Mein Krafttier ist der Wolf – loyal, verbunden, ein echter Rudelhüter 🐺"),
        QuizProfile(id:"anpassung", title:"Der Fuchs 🦊", tagline:"Meister der Anpassung und der Cleverness",
            description:"Der Fuchs erwacht in dir – clever, neugierig und mit der Gabe, in jeder Situation den richtigen Weg zu finden. Du tanzt zwischen den Welten und findest Lösungen, wo andere nur Probleme sehen.",
            icon:"wand.and.stars", color:Color(hex:"#F39C12"),
            stats:[QuizStat(label:"Cleverness", value:"97%", percent:0.97), QuizStat(label:"Anpassung", value:"93%", percent:0.93)],
            allies:["freiheit","instinkt"], shareText:"Mein Krafttier ist der Fuchs – clever, anpassungsfähig und Meister der Lösungen 🦊"),
        QuizProfile(id:"erdung", title:"Der Bär 🐻", tagline:"Kraft der Erde und des Schützens",
            description:"Der Bär steht für urzeitliche Kraft, Erdung und Schutz. Du bist jemand, der anderen Halt gibt, der standhält wenn andere weichen. Deine Stärke ist still, aber unerschütterlich.",
            icon:"mountain.2.fill", color:Color(hex:"#795548"),
            stats:[QuizStat(label:"Stärke", value:"94%", percent:0.94), QuizStat(label:"Erdung", value:"96%", percent:0.96)],
            allies:["sozial","mut"], shareText:"Mein Krafttier ist der Bär – stark, geerdet, ein stiller Beschützer 🐻"),
        QuizProfile(id:"freiheit", title:"Der Adler 🦅", tagline:"Hüter der Freiheit und des Weitblicks",
            description:"Der Adler kreist hoch über allen Grenzen. Du brauchst Freiheit wie Luft zum Atmen und besitzt einen Weitblick, der andere schwindeln lässt. Grenzen sind für dich Einladungen zum Überschreiten.",
            icon:"wind", color:Color(hex:"#00BCD4"),
            stats:[QuizStat(label:"Freiheit", value:"98%", percent:0.98), QuizStat(label:"Weitblick", value:"90%", percent:0.90)],
            allies:["mut","instinkt"], shareText:"Mein Krafttier ist der Adler – frei, weitblickend, unaufhaltbar 🦅"),
        QuizProfile(id:"instinkt", title:"Der Tiger 🐯", tagline:"Macht des Instinkts und der Präzision",
            description:"Der Tiger handelt aus tiefem Instinkt heraus – präzise, fokussiert, mit einer inneren Gewissheit die keine Worte braucht. Du vertraust deinem Bauchgefühl, weil es selten irrt.",
            icon:"bolt.fill", color:Color(hex:"#FF9800"),
            stats:[QuizStat(label:"Instinkt", value:"96%", percent:0.96), QuizStat(label:"Fokus", value:"92%", percent:0.92)],
            allies:["mut","anpassung"], shareText:"Mein Krafttier ist der Tiger – instinktsicher, präzise, kraftvoll 🐯"),
        QuizProfile(id:"vorsicht", title:"Der Hirsch 🦌", tagline:"Anmut der Stille und der inneren Kraft",
            description:"Der Hirsch verkörpert eine besondere Stärke: die Anmut, in Stille zu verharren und im richtigen Moment mit Eleganz zu agieren. Deine Sanftheit ist keine Schwäche – sie ist deine höchste Form von Kraft.",
            icon:"sparkles", color:Color(hex:"#8BC34A"),
            stats:[QuizStat(label:"Anmut", value:"93%", percent:0.93), QuizStat(label:"Innere Kraft", value:"88%", percent:0.88)],
            allies:["weisheit","klarheit"], shareText:"Mein Krafttier ist der Hirsch – anmutig, weise, in stiller Kraft 🦌"),
    ],
    dimensions: ["mut","weisheit","sozial","anpassung","erdung","freiheit","instinkt","vorsicht","klarheit"]
)

// MARK: - RPG Identitäts-Quiz (12 Fragen, 8 Profile)

let rpgQuiz = FullQuiz(
    id: "quiz.rpg_identity.v1",
    title: "Deine Rollenspiel-Seele",
    subtitle: "Welche RPG-Klasse bist du wirklich?",
    icon: "shield.fill",
    color: Color(hex: "#7C5CBF"),
    estimatedMinutes: 3,
    questions: [
        QuizQuestion(id:"q1", text:"Was ist dein erster Instinkt?",
            context:"Du betrittst einen Dungeon. Am Eingang liegt ein verwundeter Fremder.",
            options:[
                QuizOption(id:"a", text:"Ich heile ihn – niemand sollte allein leiden", scores:["connection":3,"clarity":1]),
                QuizOption(id:"b", text:"Ich frage, wer ihn angegriffen hat – Informationen zuerst", scores:["clarity":3,"courage":1]),
                QuizOption(id:"c", text:"Ich nehme seine Ausrüstung – er braucht sie nicht mehr", scores:["shadow":3,"order":-1]),
                QuizOption(id:"d", text:"Ich untersuche die Spuren – der Angreifer könnte noch hier sein", scores:["clarity":3,"order":1]),
            ]),
        QuizQuestion(id:"q2", text:"Wie antwortest du?",
            context:"Ein mächtiger Drache bietet dir einen Pakt an: Macht gegen einen Teil deiner Erinnerungen.",
            options:[
                QuizOption(id:"a", text:"Niemals. Meine Vergangenheit macht mich aus.", scores:["order":3,"connection":1]),
                QuizOption(id:"b", text:"Ich verhandele – vielleicht gibt es eine Lücke im Pakt", scores:["clarity":3,"courage":1]),
                QuizOption(id:"c", text:"Ich greife ihn an – Drachen lügen immer", scores:["courage":3,"shadow":1]),
                QuizOption(id:"d", text:"Ich akzeptiere. Macht ist wichtiger als Sentimentalität.", scores:["shadow":3,"order":-1]),
            ]),
        QuizQuestion(id:"q3", text:"Welches Schloss übernimmst du?",
            context:"Deine Gruppe steht vor einer verschlossenen Tür mit drei Schlössern.",
            options:[
                QuizOption(id:"a", text:"Das Magische – Intelligenz öffnet alle Türen", scores:["clarity":3,"order":2]),
                QuizOption(id:"b", text:"Das Soziale – ich überrede den Wächter", scores:["connection":3,"clarity":1]),
                QuizOption(id:"c", text:"Das Physische – ich breche es einfach auf", scores:["courage":3,"order":1]),
                QuizOption(id:"d", text:"Ich finde einen anderen Eingang", scores:["clarity":2,"courage":2,"shadow":1]),
            ]),
        QuizQuestion(id:"q4", text:"Was antreibt dich wirklich?",
            context:"Du bist nun seit Monaten auf Abenteuern. Warum machst du weiter?",
            options:[
                QuizOption(id:"a", text:"Um diejenigen zu schützen, die mich brauchen", scores:["connection":4,"courage":2]),
                QuizOption(id:"b", text:"Weil ich die Wahrheit über die Welt verstehen will", scores:["clarity":4,"order":2]),
                QuizOption(id:"c", text:"Weil ich meine Grenzen testen will", scores:["courage":4,"shadow":1]),
                QuizOption(id:"d", text:"Weil ich Macht will – echte, dauerhafte Macht", scores:["shadow":4,"order":1]),
            ]),
        QuizQuestion(id:"q5", text:"Dein Begleiter ist in Lebensgefahr. Was tust du?",
            context:"Ein Kampf geht verloren. Dein Begleiter liegt am Boden.",
            options:[
                QuizOption(id:"a", text:"Ich werfe mich zwischen ihn und den Feind", scores:["courage":4,"connection":3]),
                QuizOption(id:"b", text:"Ich rufe einen Rückzug und rette ihn strategisch", scores:["clarity":3,"order":3]),
                QuizOption(id:"c", text:"Ich wecke in mir dunkle Energie auf, die ich sonst vergrabe", scores:["shadow":4,"courage":2]),
                QuizOption(id:"d", text:"Ich heile ihn mit allem, was ich habe", scores:["connection":4,"clarity":1]),
            ]),
        QuizQuestion(id:"q6", text:"Was erschreckt dich am meisten?",
            context:"Du stehst vor deiner tiefsten Angst.",
            options:[
                QuizOption(id:"a", text:"Irrelevant zu sein – niemanden zu brauchen", scores:["connection":4,"courage":1]),
                QuizOption(id:"b", text:"Die Kontrolle zu verlieren", scores:["order":4,"clarity":2]),
                QuizOption(id:"c", text:"Schwach zu wirken", scores:["shadow":3,"courage":2]),
                QuizOption(id:"d", text:"Nicht verstehen, warum Dinge so sind wie sie sind", scores:["clarity":4,"order":2]),
            ]),
        QuizQuestion(id:"q7", text:"Wie lernst du am besten?",
            context:"Du bist Lehrling bei einem alten Meister.",
            options:[
                QuizOption(id:"a", text:"Durch Fehler und direkte Erfahrung", scores:["courage":3,"shadow":1]),
                QuizOption(id:"b", text:"Durch Beobachtung anderer Meister", scores:["clarity":3,"order":2]),
                QuizOption(id:"c", text:"Durch das Lehren anderer", scores:["connection":3,"clarity":2]),
                QuizOption(id:"d", text:"Durch Grenzgänge – an den Rändern des Erlaubten", scores:["shadow":3,"courage":2]),
            ]),
        QuizQuestion(id:"q8", text:"Was ist deine verborgene Stärke?",
            context:"In deiner dunkelsten Stunde tritt etwas in dir hervor.",
            options:[
                QuizOption(id:"a", text:"Unerschütterliche Entschlossenheit", scores:["courage":4,"order":2]),
                QuizOption(id:"b", text:"Tiefes Empathievermögen", scores:["connection":4,"clarity":1]),
                QuizOption(id:"c", text:"Strategische Kaltblütigkeit", scores:["clarity":4,"shadow":2]),
                QuizOption(id:"d", text:"Zugang zu Kräften, die andere nicht einmal ahnen", scores:["shadow":4,"clarity":2]),
            ]),
        QuizQuestion(id:"q9", text:"Wie behandelst du Feinde?",
            context:"Der Bösewicht liegt besiegt zu deinen Füßen.",
            options:[
                QuizOption(id:"a", text:"Ich gebe ihm eine Chance zur Reue", scores:["connection":3,"order":2]),
                QuizOption(id:"b", text:"Ich übergebe ihn der Gerechtigkeit", scores:["order":4,"clarity":2]),
                QuizOption(id:"c", text:"Ich eliminiere die Bedrohung dauerhaft", scores:["shadow":3,"courage":2]),
                QuizOption(id:"d", text:"Ich versuche, seinen Beweggrund zu verstehen", scores:["clarity":3,"connection":2]),
            ]),
        QuizQuestion(id:"q10", text:"Was siehst du, wenn du in einen magischen Spiegel blickst?",
            context:"Ein Zauberspiegel zeigt dir dein wahres Selbst.",
            options:[
                QuizOption(id:"a", text:"Eine Figur, umgeben von Licht und Heilung", scores:["connection":4,"order":2]),
                QuizOption(id:"b", text:"Einen Weisen, der alle Fäden kennt", scores:["clarity":4,"order":3]),
                QuizOption(id:"c", text:"Eine dunkle Gestalt, voller unentfesselter Kraft", scores:["shadow":4,"courage":2]),
                QuizOption(id:"d", text:"Ein Wesen zwischen Welten – weder ganz hell noch ganz dunkel", scores:["shadow":2,"clarity":2,"connection":2]),
            ]),
        QuizQuestion(id:"q11", text:"Was ist deine Rolle in der Gruppe?",
            context:"Deine Reisegruppe steht vor einer wichtigen Entscheidung.",
            options:[
                QuizOption(id:"a", text:"Ich sorge dafür, dass alle sicher sind und gehört werden", scores:["connection":4,"order":2]),
                QuizOption(id:"b", text:"Ich analysiere alle Optionen und präsentiere den besten Plan", scores:["clarity":4,"order":3]),
                QuizOption(id:"c", text:"Ich tue, was nötig ist – auch wenn es niemand sonst täte", scores:["shadow":3,"courage":3]),
                QuizOption(id:"d", text:"Ich führe die Gruppe in den Kampf", scores:["courage":4,"order":2]),
            ]),
        QuizQuestion(id:"q12", text:"Wie endet deine Geschichte?",
            context:"Am Ende deiner Reise – wie wird man sich an dich erinnern?",
            options:[
                QuizOption(id:"a", text:"Als jemanden, der eine Welt repariert hat, die zerbrochen war", scores:["connection":4,"clarity":2]),
                QuizOption(id:"b", text:"Als Architekten einer neuen Ordnung", scores:["order":4,"clarity":2]),
                QuizOption(id:"c", text:"Als das Rätsel, das niemand ganz lösen konnte", scores:["shadow":4,"clarity":2]),
                QuizOption(id:"d", text:"Als den Mutigsten, der je lebte", scores:["courage":4,"shadow":1]),
            ]),
    ],
    profiles: [
        QuizProfile(id:"courage", title:"⚔️ Der Krieger des Schicksals", tagline:"Du trägst die Last der Welt auf Schultern aus Stahl.",
            description:"Du bist die erste Klinge in jedem Kampf und der letzte Schild wenn alle anderen fallen. Mut ist nicht das Fehlen von Angst – es ist die Entscheidung, trotzdem voranzugehen. Und genau das tust du, wieder und wieder.",
            icon:"shield.fill", color:Color(hex:"#E74C3C"),
            stats:[QuizStat(label:"Angriff", value:"97%", percent:0.97), QuizStat(label:"Mut", value:"95%", percent:0.95)],
            allies:["shadow","order"], shareText:"Meine RPG-Klasse ist der Krieger – furchtlos, unerschütterlich, der erste im Kampf ⚔️"),
        QuizProfile(id:"clarity", title:"🧙 Der Magier der Wahrheit", tagline:"Du siehst die Muster, die andere nicht einmal erahnen.",
            description:"Für dich ist Wissen die mächtigste Kraft im Universum. Du analysierst, planst und weißt oft schon drei Züge voraus. Deine Intelligenz ist deine schärfste Waffe – und auch dein größter Fluch.",
            icon:"wand.and.stars", color:Color(hex:"#9B59B6"),
            stats:[QuizStat(label:"Intelligenz", value:"98%", percent:0.98), QuizStat(label:"Strategie", value:"94%", percent:0.94)],
            allies:["order","connection"], shareText:"Meine RPG-Klasse ist der Magier – weise, strategisch, drei Schritte voraus 🧙"),
        QuizProfile(id:"connection", title:"✨ Der Heiler der Verbindung", tagline:"Deine Stärke liegt darin, was du zusammenhältst.",
            description:"Du besitzt die seltene Gabe, zu heilen was zerbrochen ist – in Menschen, in Beziehungen, in Gemeinschaften. Deine Empathie ist deine Superkraft, und dein Herz ist dein stärkstes Instrument.",
            icon:"heart.fill", color:Color(hex:"#52A853"),
            stats:[QuizStat(label:"Empathie", value:"97%", percent:0.97), QuizStat(label:"Heilung", value:"96%", percent:0.96)],
            allies:["clarity","courage"], shareText:"Meine RPG-Klasse ist der Heiler – empathisch, verbindend, die Seele der Gruppe ✨"),
        QuizProfile(id:"order", title:"🛡️ Der Paladin der Ordnung", tagline:"Du bist der Anker, wenn die Welt aus den Fugen gerät.",
            description:"Du lebst nach einem strengen inneren Kodex und verlangst von dir und anderen absolute Integrität. Du bist Schutzschild und Richter zugleich – unbeugsam im Prinzip, unerschütterlich in der Ausführung.",
            icon:"checkmark.shield.fill", color:Color(hex:"#4A85C4"),
            stats:[QuizStat(label:"Disziplin", value:"96%", percent:0.96), QuizStat(label:"Integrität", value:"98%", percent:0.98)],
            allies:["clarity","connection"], shareText:"Meine RPG-Klasse ist der Paladin – gerecht, diszipliniert, unerschütterlich 🛡️"),
        QuizProfile(id:"shadow", title:"🌑 Der Schattenläufer", tagline:"Du existierst dort, wo Licht und Dunkel sich berühren.",
            description:"Du bist derjenige, der die Dinge tut, die sonst niemand tun würde. Nicht aus Bosheit – sondern weil du weißt, dass manche Wahrheiten nur im Dunkeln zu finden sind. Deine moralische Komplexität ist deine größte Stärke.",
            icon:"moon.stars.fill", color:Color(hex:"#37474F"),
            stats:[QuizStat(label:"Schatten", value:"94%", percent:0.94), QuizStat(label:"Komplexität", value:"96%", percent:0.96)],
            allies:["clarity","courage"], shareText:"Meine RPG-Klasse ist der Schattenläufer – zwischen den Welten, ungreifbar und mächtig 🌑"),
    ],
    dimensions: ["courage","clarity","connection","order","shadow"]
)

// MARK: - Energiestein-Quiz (10 Fragen, 8 Profile)

let energiesteinQuiz = FullQuiz(
    id: "quiz.energiestein.v1",
    title: "Dein Energiestein",
    subtitle: "Welcher Kristall resoniert mit deiner Seele?",
    icon: "sparkles",
    color: Color(hex: "#9B59B6"),
    estimatedMinutes: 3,
    questions: [
        QuizQuestion(id:"q1", text:"Du betrittst eine Kristallhöhle. Welches Licht zieht dich zuerst an?",
            context:"",
            options:[
                QuizOption(id:"a", text:"Ein sanftes violettes Glimmen aus der Tiefe", scores:["clarity":2,"energy":1,"focus":3]),
                QuizOption(id:"b", text:"Klare, weiße Lichtreflexionen an den Wänden", scores:["clarity":5,"energy":2,"focus":2]),
                QuizOption(id:"c", text:"Warme, goldene Strahlen durch einen Spalt", scores:["clarity":3,"energy":4,"focus":4]),
                QuizOption(id:"d", text:"Tiefes Schwarz mit einzelnen Funken", scores:["clarity":1,"energy":5,"focus":1]),
            ]),
        QuizQuestion(id:"q2", text:"Wenn du einen Stein in der Hand hältst, was spürst du am liebsten?",
            context:"",
            options:[
                QuizOption(id:"a", text:"Eine beruhigende Kühle, die mich erdet", scores:["clarity":4,"energy":1,"focus":2]),
                QuizOption(id:"b", text:"Ein leichtes Kribbeln wie elektrische Spannung", scores:["clarity":2,"energy":5,"focus":4]),
                QuizOption(id:"c", text:"Eine sanfte Wärme, die durch mich fließt", scores:["clarity":3,"energy":3,"focus":3]),
                QuizOption(id:"d", text:"Das Gewicht und die Präsenz des Moments", scores:["clarity":1,"energy":2,"focus":1]),
            ]),
        QuizQuestion(id:"q3", text:"In einem wichtigen Gespräch – was ist dir am wichtigsten?",
            context:"",
            options:[
                QuizOption(id:"a", text:"Ehrliche Worte, auch wenn sie wehtun", scores:["clarity":5,"energy":2,"focus":3]),
                QuizOption(id:"b", text:"Die Energie im Raum spüren, bevor ich spreche", scores:["clarity":2,"energy":4,"focus":2]),
                QuizOption(id:"c", text:"Klare Struktur und Logik", scores:["clarity":4,"energy":1,"focus":5]),
                QuizOption(id:"d", text:"Tiefe emotionale Verbindung", scores:["clarity":3,"energy":3,"focus":2]),
            ]),
        QuizQuestion(id:"q4", text:"Wie lädst du dich am besten auf?",
            context:"",
            options:[
                QuizOption(id:"a", text:"In der Natur, ohne Handy, ohne Stimmen", scores:["clarity":4,"energy":2,"focus":1]),
                QuizOption(id:"b", text:"Beim Sport – intensive Bewegung, Schweiß", scores:["clarity":1,"energy":5,"focus":3]),
                QuizOption(id:"c", text:"Bei meditativer Stille, tiefer Atmung", scores:["clarity":5,"energy":1,"focus":2]),
                QuizOption(id:"d", text:"In intellektuell stimulierenden Gesprächen", scores:["clarity":3,"energy":3,"focus":5]),
            ]),
        QuizQuestion(id:"q5", text:"Du findest einen alten Brief. Was hoffst du darin zu lesen?",
            context:"",
            options:[
                QuizOption(id:"a", text:"Eine unbekannte Wahrheit über dich selbst", scores:["clarity":5,"energy":2,"focus":3]),
                QuizOption(id:"b", text:"Eine Prophezeiung für deine Zukunft", scores:["clarity":2,"energy":5,"focus":4]),
                QuizOption(id:"c", text:"Praktische Weisheit für jetzt", scores:["clarity":3,"energy":2,"focus":5]),
                QuizOption(id:"d", text:"Worte tiefer Liebe", scores:["clarity":2,"energy":3,"focus":2]),
            ]),
        QuizQuestion(id:"q6", text:"Wenn dich jemand beobachtet – was soll er sehen?",
            context:"",
            options:[
                QuizOption(id:"a", text:"Jemanden mit klarem Blick und ruhiger Würde", scores:["clarity":5,"energy":1,"focus":3]),
                QuizOption(id:"b", text:"Energie und Intensität, die man spürt", scores:["clarity":1,"energy":5,"focus":2]),
                QuizOption(id:"c", text:"Struktur und Verlässlichkeit", scores:["clarity":3,"energy":1,"focus":5]),
                QuizOption(id:"d", text:"Wärme und Offenheit", scores:["clarity":2,"energy":3,"focus":2]),
            ]),
        QuizQuestion(id:"q7", text:"Was bedeutet Heilung für dich?",
            context:"",
            options:[
                QuizOption(id:"a", text:"Klarheit – wenn der Nebel sich lichtet", scores:["clarity":5,"energy":2,"focus":2]),
                QuizOption(id:"b", text:"Energie – wenn die Kraft zurückkommt", scores:["clarity":1,"energy":5,"focus":3]),
                QuizOption(id:"c", text:"Fokus – wenn ich wieder weiß, wohin", scores:["clarity":2,"energy":2,"focus":5]),
                QuizOption(id:"d", text:"Verbindung – wenn ich wieder berühren kann", scores:["clarity":3,"energy":3,"focus":2]),
            ]),
        QuizQuestion(id:"q8", text:"Du musst eine schwere Entscheidung treffen. Was tust du?",
            context:"",
            options:[
                QuizOption(id:"a", text:"Ich meditiere, bis die Antwort kommt", scores:["clarity":5,"energy":1,"focus":2]),
                QuizOption(id:"b", text:"Ich handle jetzt – Instinkt ist Weisheit", scores:["clarity":1,"energy":5,"focus":4]),
                QuizOption(id:"c", text:"Ich analysiere alle Optionen systematisch", scores:["clarity":3,"energy":1,"focus":5]),
                QuizOption(id:"d", text:"Ich vertraue meinem Bauchgefühl", scores:["clarity":2,"energy":4,"focus":2]),
            ]),
        QuizQuestion(id:"q9", text:"Welche Jahreszeit resoniert am tiefsten mit dir?",
            context:"",
            options:[
                QuizOption(id:"a", text:"Herbst – Loslassen, Transformation, Klarheit", scores:["clarity":5,"energy":2,"focus":3]),
                QuizOption(id:"b", text:"Sommer – Feuer, Energie, Entfaltung", scores:["clarity":1,"energy":5,"focus":3]),
                QuizOption(id:"c", text:"Winter – Stille, Tiefe, Konzentration", scores:["clarity":3,"energy":1,"focus":5]),
                QuizOption(id:"d", text:"Frühling – Neubeginn, Wachstum, Hoffnung", scores:["clarity":2,"energy":3,"focus":2]),
            ]),
        QuizQuestion(id:"q10", text:"Was ist deine Beziehung zur Dunkelheit?",
            context:"",
            options:[
                QuizOption(id:"a", text:"Sie zeigt mir, was ich nicht sehe im Licht", scores:["clarity":5,"energy":2,"focus":3]),
                QuizOption(id:"b", text:"Sie gibt mir Energie – ich bin ein Nachtmensch", scores:["clarity":1,"energy":5,"focus":2]),
                QuizOption(id:"c", text:"Sie hilft mir, mich zu fokussieren", scores:["clarity":2,"energy":1,"focus":5]),
                QuizOption(id:"d", text:"Sie erinnert mich an die Tiefe meiner Gefühle", scores:["clarity":3,"energy":3,"focus":2]),
            ]),
    ],
    profiles: [
        QuizProfile(id:"clarity", title:"Amethyst 💜", tagline:"Stein der spirituellen Klarheit und inneren Weisheit",
            description:"Der Amethyst ist dein Stein – er trägt die Frequenz tiefer Klarheit und spiritueller Einsicht. Du siehst unter die Oberfläche der Dinge, verarbeitest emotional tiefgründig und suchst nach der Wahrheit hinter der Wirklichkeit.",
            icon:"eye.fill", color:Color(hex:"#9B59B6"),
            stats:[QuizStat(label:"Klarheit", value:"96%", percent:0.96), QuizStat(label:"Intuition", value:"93%", percent:0.93)],
            allies:["bergkristall","rosenquarz"], shareText:"Mein Energiestein ist der Amethyst – Klarheit, Tiefe und spirituelle Weisheit 💜"),
        QuizProfile(id:"energy", title:"Roter Jaspis 🔴", tagline:"Stein der Lebensenergie und Entschlossenheit",
            description:"Der rote Jaspis ist dein Stein der Kraft. Er trägt die Energie des Feuers und der Erde zugleich – stabilisierend, energetisierend, erdend. Du handelst aus einem tiefen Antrieb heraus.",
            icon:"flame.fill", color:Color(hex:"#E74C3C"),
            stats:[QuizStat(label:"Energie", value:"97%", percent:0.97), QuizStat(label:"Ausdauer", value:"91%", percent:0.91)],
            allies:["tigerauge","obsidian"], shareText:"Mein Energiestein ist roter Jaspis – pure Lebensenergie und Entschlossenheit 🔴"),
        QuizProfile(id:"focus", title:"Bergkristall ⬜", tagline:"Stein der reinen Klarheit und des Fokus",
            description:"Der Bergkristall ist der Meister aller Kristalle – klar, rein und unendlich vielseitig. Er verstärkt alles, was du hineinbringst, und hilft dir, dich auf das Wesentliche zu fokussieren.",
            icon:"target", color:Color(hex:"#78909C"),
            stats:[QuizStat(label:"Fokus", value:"98%", percent:0.98), QuizStat(label:"Klarheit", value:"95%", percent:0.95)],
            allies:["amethyst","mondstein"], shareText:"Mein Energiestein ist Bergkristall – reiner Fokus und universelle Klarheit ⬜"),
    ],
    dimensions: ["clarity","energy","focus"]
)

// MARK: - Party-Bedürfnis-Quiz (6 Fragen, 4 Profile)

let partyQuiz = FullQuiz(
    id: "quiz.party_need.v1",
    title: "Dein Party-Bedürfnis",
    subtitle: "Wie viel Feiern steckt wirklich in dir?",
    icon: "music.note",
    color: Color(hex: "#FF6B6B"),
    estimatedMinutes: 2,
    questions: [
        QuizQuestion(id:"q1", text:"Dein Handy vibriert: Hey, wir sind spontan am Fluss – kommst du?",
            context:"Freitagabend, 19:30 Uhr. Du hattest Netflix eingeplant.",
            options:[
                QuizOption(id:"a", text:"Bin schon im Pyjama – nächstes Mal! 🛋️", scores:["event_drive":10,"stimulus_seeking":15]),
                QuizOption(id:"b", text:"Wer kommt noch? Und wie laut wird es? 🤔", scores:["event_drive":45,"stimulus_seeking":35]),
                QuizOption(id:"c", text:"Gib mir 10 Minuten! 🏃", scores:["event_drive":75,"stimulus_seeking":60]),
                QuizOption(id:"d", text:"Ich bring die Boxen mit! 🔊", scores:["event_drive":95,"stimulus_seeking":95]),
            ]),
        QuizQuestion(id:"q2", text:"24 Stunden für dich. Was passiert?",
            context:"Dein perfekter Samstag. Keine Verpflichtungen. Totale Freiheit.",
            options:[
                QuizOption(id:"a", text:"Buch, Tee, langer Spaziergang allein 🌿", scores:["event_drive":10,"stimulus_seeking":20]),
                QuizOption(id:"b", text:"Brunch mit 2-3 engen Freunden, dann chillen 🥐", scores:["event_drive":40,"stimulus_seeking":40]),
                QuizOption(id:"c", text:"Tagsüber Flohmarkt, abends Hausparty 🎈", scores:["event_drive":75,"stimulus_seeking":70]),
                QuizOption(id:"d", text:"Dayparty, Dinner, Club bis Sunrise 💫", scores:["event_drive":100,"stimulus_seeking":100]),
            ]),
        QuizQuestion(id:"q3", text:"Große Geburtstagsparty – 80 Leute, DJ, Open Bar.",
            context:"Die Mail landet in deinem Postfach. Dein erster Gedanke?",
            options:[
                QuizOption(id:"a", text:"Innerliches Uff – klingt anstrengend 😅", scores:["event_drive":15,"stimulus_seeking":15]),
                QuizOption(id:"b", text:"Komm kurz vorbei, sage Happy Birthday ⏱️", scores:["event_drive":45,"stimulus_seeking":30]),
                QuizOption(id:"c", text:"Ich freu mich – aber Fluchtplan hab ich 🚪", scores:["event_drive":65,"stimulus_seeking":55]),
                QuizOption(id:"d", text:"JA! Wann? Wo? Was zieh ich an?! 🎉", scores:["event_drive":95,"stimulus_seeking":85]),
            ]),
        QuizQuestion(id:"q4", text:"Du kommst von einer 3-Stunden-Party nach Hause.",
            context:"Post-Party Check. Es ist 23 Uhr.",
            options:[
                QuizOption(id:"a", text:"Leer. Brauch mindestens 2 Tage Social-Detox 😮‍💨", scores:["event_drive":15,"stimulus_seeking":10]),
                QuizOption(id:"b", text:"Zufrieden, aber genug für heute ✓", scores:["event_drive":40,"stimulus_seeking":35]),
                QuizOption(id:"c", text:"Energetisiert – war cool, aber jetzt Ruhe 😌", scores:["event_drive":60,"stimulus_seeking":65]),
                QuizOption(id:"d", text:"Hyped! Warte, wo geht es weiter? 🔥", scores:["event_drive":95,"stimulus_seeking":100]),
            ]),
        QuizQuestion(id:"q5", text:"Deine ideale Abend-Atmosphäre klingt wie...",
            context:"Die Lautstärke-Frage. Schließ kurz die Augen.",
            options:[
                QuizOption(id:"a", text:"Stille oder sanfter Regen am Fenster 🌧️", scores:["event_drive":10,"stimulus_seeking":5]),
                QuizOption(id:"b", text:"Leise Hintergrundmusik, Stimmengewirr 🎵", scores:["event_drive":40,"stimulus_seeking":35]),
                QuizOption(id:"c", text:"Musik die man mitsingt, Gelächter 🎤", scores:["event_drive":70,"stimulus_seeking":65]),
                QuizOption(id:"d", text:"Bass der durch den Boden geht, Menschenmenge 🎧", scores:["event_drive":95,"stimulus_seeking":95]),
            ]),
        QuizQuestion(id:"q6", text:"Drei Tage Wochenende. Alle Freunde sind verfügbar.",
            context:"Der ultimative Test. Was planst du?",
            options:[
                QuizOption(id:"a", text:"Ich genieße die seltene Ruhe 🌙", scores:["event_drive":10,"stimulus_seeking":15]),
                QuizOption(id:"b", text:"Ein gemeinsamer Abend – nicht mehr 🏡", scores:["event_drive":35,"stimulus_seeking":30]),
                QuizOption(id:"c", text:"Zwei Tage Events, ein Tag Erholung ⚖️", scores:["event_drive":65,"stimulus_seeking":60]),
                QuizOption(id:"d", text:"Vollgas durch – FOMO ist keine Option 🚀", scores:["event_drive":100,"stimulus_seeking":95]),
            ]),
    ],
    profiles: [
        QuizProfile(id:"low", title:"🌙 Der Mondmensch", tagline:"Tiefe Stille ist dein natürlicher Zustand",
            description:"Du lebst in einer Welt, die oft zu laut ist. Du brauchst Stille nicht als Flucht, sondern als Heimat. Kleine, intensive Verbindungen bedeuten dir mehr als große Massen. Du regenerierst allein und in der Tiefe.",
            icon:"moon.fill", color:Color(hex:"#4A85C4"),
            stats:[QuizStat(label:"Introversion", value:"89%", percent:0.89), QuizStat(label:"Tiefe", value:"95%", percent:0.95)],
            allies:[], shareText:"Mein Party-Typ: Der Mondmensch – ich wähle Tiefe über Lautstärke 🌙"),
        QuizProfile(id:"mid", title:"⚖️ Der Architekt", tagline:"Du weißt genau, was du brauchst – und wie viel",
            description:"Du liebst das Feiern – aber zu deinen Bedingungen. Du planst, du strukturierst, du hast immer einen Ausweg. Dein Sweet Spot liegt in kontrollierten Events mit ausgewählten Menschen.",
            icon:"square.stack.fill", color:Color(hex:"#52A853"),
            stats:[QuizStat(label:"Balance", value:"92%", percent:0.92), QuizStat(label:"Kontrolle", value:"88%", percent:0.88)],
            allies:[], shareText:"Mein Party-Typ: Der Architekt – ich feiere strategisch und mit Plan ⚖️"),
        QuizProfile(id:"high", title:"🎉 Der Pulse", tagline:"Du bist die Energie, die anderen fehlt wenn du nicht da bist",
            description:"Du liebst das Leben in vollen Zügen. Events laden dich auf, Menschen geben dir Energie, und wenn die Musik läuft, bist du in deinem Element. Du bist oft derjenige, der die Party erst zur Party macht.",
            icon:"bolt.fill", color:Color(hex:"#FF9800"),
            stats:[QuizStat(label:"Energie", value:"96%", percent:0.96), QuizStat(label:"Präsenz", value:"93%", percent:0.93)],
            allies:[], shareText:"Mein Party-Typ: Der Pulse – ich bringe die Energie 🎉"),
        QuizProfile(id:"ultra", title:"🔥 Der Zeitgeist", tagline:"Du bist das Ereignis – nicht nur dabei",
            description:"Für dich existiert ein Leben jenseits von Events nur in der Theorie. Du bist der letzte auf der Tanzfläche, der erste bei der nächsten Einladung und der einzige, der am Montagmorgen noch strahlt.",
            icon:"flame.fill", color:Color(hex:"#E74C3C"),
            stats:[QuizStat(label:"Sozialmasse", value:"99%", percent:0.99), QuizStat(label:"Energie", value:"98%", percent:0.98)],
            allies:[], shareText:"Mein Party-Typ: Der Zeitgeist – das Leben ist die Party 🔥"),
    ],
    dimensions: ["event_drive","stimulus_seeking"]
)

// MARK: - Blumenwesen-Quiz (10 Fragen, 8 Profile)

let blumenwesenQuiz = FullQuiz(
    id: "quiz.flower_being.v1",
    title: "Dein Blumenwesen",
    subtitle: "Welche Blume trägt dein inneres Wesen?",
    icon: "leaf.fill",
    color: Color(hex: "#8BC34A"),
    estimatedMinutes: 3,
    questions: [
        QuizQuestion(id:"q1", text:"Wo wächst deine Blume?",
            context:"Der innere Garten",
            options:[
                QuizOption(id:"a", text:"Mitten im Sonnenlicht, wo jeder sie sehen kann", scores:["licht":5,"wurzeln":3,"rhythmus":4,"wasser":3]),
                QuizOption(id:"b", text:"Versteckt in einer schattigen Ecke, nur für wenige sichtbar", scores:["licht":2,"wurzeln":5,"rhythmus":2,"wasser":4]),
                QuizOption(id:"c", text:"An einem Ort, der sich verändert – mal hier, mal dort", scores:["licht":3,"wurzeln":1,"rhythmus":5,"wasser":2]),
                QuizOption(id:"d", text:"Am Rand des Wassers, immer in Bewegung", scores:["licht":3,"wurzeln":2,"rhythmus":4,"wasser":5]),
            ]),
        QuizQuestion(id:"q2", text:"Was brauchst du zum Gedeihen?",
            context:"Die Bedürfnisse deines inneren Wesens",
            options:[
                QuizOption(id:"a", text:"Sonnenlicht und Raum – ich brauche Weite", scores:["licht":5,"wurzeln":2,"rhythmus":3,"wasser":2]),
                QuizOption(id:"b", text:"Tiefe Erde und Stille – Verwurzelung", scores:["licht":2,"wurzeln":5,"rhythmus":2,"wasser":3]),
                QuizOption(id:"c", text:"Wechsel und Bewegung – Stillstand tötet mich", scores:["licht":3,"wurzeln":1,"rhythmus":5,"wasser":3]),
                QuizOption(id:"d", text:"Tiefes Wasser und Reinheit", scores:["licht":2,"wurzeln":3,"rhythmus":3,"wasser":5]),
            ]),
        QuizQuestion(id:"q3", text:"Wie blühst du auf?",
            context:"Dein Moment der vollsten Entfaltung",
            options:[
                QuizOption(id:"a", text:"Wenn ich im Mittelpunkt sein darf und strahle", scores:["licht":5,"wurzeln":2,"rhythmus":3,"wasser":2]),
                QuizOption(id:"b", text:"Wenn ich tief verwurzelt und sicher bin", scores:["licht":2,"wurzeln":5,"rhythmus":2,"wasser":3]),
                QuizOption(id:"c", text:"Wenn ich mich frei entfalten und wandeln kann", scores:["licht":3,"wurzeln":1,"rhythmus":5,"wasser":3]),
                QuizOption(id:"d", text:"Wenn ich in tiefer Verbindung bin", scores:["licht":3,"wurzeln":3,"rhythmus":3,"wasser":5]),
            ]),
        QuizQuestion(id:"q4", text:"Wie reagierst du auf Sturm?",
            context:"Eine schwere Zeit kommt über dich.",
            options:[
                QuizOption(id:"a", text:"Ich beuge mich im Wind, aber breche nicht", scores:["licht":4,"wurzeln":3,"rhythmus":4,"wasser":2]),
                QuizOption(id:"b", text:"Meine Wurzeln halten mich – ich stehe fest", scores:["licht":2,"wurzeln":5,"rhythmus":2,"wasser":3]),
                QuizOption(id:"c", text:"Ich lasse mich mitreißen und finde mich neu", scores:["licht":3,"wurzeln":1,"rhythmus":5,"wasser":4]),
                QuizOption(id:"d", text:"Ich gehe in mich – wie ein Lotus im Schlamm", scores:["licht":2,"wurzeln":3,"rhythmus":3,"wasser":5]),
            ]),
        QuizQuestion(id:"q5", text:"Welcher Rhythmus beschreibt dich am besten?",
            context:"Dein innerer Takt",
            options:[
                QuizOption(id:"a", text:"Jeden Tag aufblühen, am Abend ruhen – regelmäßig", scores:["licht":4,"wurzeln":3,"rhythmus":4,"wasser":2]),
                QuizOption(id:"b", text:"Langsam, tief und beständig", scores:["licht":2,"wurzeln":5,"rhythmus":2,"wasser":3]),
                QuizOption(id:"c", text:"Mal wild, mal still – unvorhersehbar", scores:["licht":3,"wurzeln":1,"rhythmus":5,"wasser":3]),
                QuizOption(id:"d", text:"Fließend, wie das Wasser das immer weitergeht", scores:["licht":2,"wurzeln":2,"rhythmus":4,"wasser":5]),
            ]),
        QuizQuestion(id:"q6", text:"Was beschreibt deine Schönheit am besten?",
            context:"Wie würden andere dich beschreiben?",
            options:[
                QuizOption(id:"a", text:"Strahlend und unübersehbar – man sieht mich sofort", scores:["licht":5,"wurzeln":2,"rhythmus":3,"wasser":2]),
                QuizOption(id:"b", text:"Tiefgründig und majestätisch – man muss genau hinschauen", scores:["licht":2,"wurzeln":5,"rhythmus":2,"wasser":4]),
                QuizOption(id:"c", text:"Wild und unkonventionell – anders als andere", scores:["licht":3,"wurzeln":1,"rhythmus":5,"wasser":3]),
                QuizOption(id:"d", text:"Zart und rein – eine stille Schönheit", scores:["licht":3,"wurzeln":3,"rhythmus":2,"wasser":5]),
            ]),
        QuizQuestion(id:"q7", text:"Was schützt dich?",
            context:"Dein natürlicher Schutz",
            options:[
                QuizOption(id:"a", text:"Meine Auffälligkeit – ich zeige, wer ich bin", scores:["licht":5,"wurzeln":2,"rhythmus":3,"wasser":2]),
                QuizOption(id:"b", text:"Meine Wurzeln – was ich aufgebaut habe", scores:["licht":2,"wurzeln":5,"rhythmus":2,"wasser":3]),
                QuizOption(id:"c", text:"Meine Anpassungsfähigkeit", scores:["licht":3,"wurzeln":2,"rhythmus":5,"wasser":3]),
                QuizOption(id:"d", text:"Meine Tiefe – man erreicht mich nicht so leicht", scores:["licht":2,"wurzeln":3,"rhythmus":3,"wasser":5]),
            ]),
        QuizQuestion(id:"q8", text:"Was bedeutet Verwelken für dich?",
            context:"Was bringt dich aus der Balance?",
            options:[
                QuizOption(id:"a", text:"Keine Aufmerksamkeit mehr, übersehen werden", scores:["licht":5,"wurzeln":1,"rhythmus":2,"wasser":1]),
                QuizOption(id:"b", text:"Aus der Erde gerissen werden, bindungslos sein", scores:["licht":1,"wurzeln":5,"rhythmus":1,"wasser":2]),
                QuizOption(id:"c", text:"Erzwungene Routine, Stillstand", scores:["licht":2,"wurzeln":1,"rhythmus":5,"wasser":2]),
                QuizOption(id:"d", text:"Verschmutzung, Oberflächlichkeit, Unehrlichkeit", scores:["licht":2,"wurzeln":3,"rhythmus":2,"wasser":5]),
            ]),
        QuizQuestion(id:"q9", text:"Wie gibst du dein Geschenk weiter?",
            context:"Was schenkst du der Welt?",
            options:[
                QuizOption(id:"a", text:"Durch meinen Glanz – ich erhelle Räume", scores:["licht":5,"wurzeln":2,"rhythmus":3,"wasser":2]),
                QuizOption(id:"b", text:"Durch Beständigkeit – ich bin da, immer", scores:["licht":2,"wurzeln":5,"rhythmus":2,"wasser":3]),
                QuizOption(id:"c", text:"Durch Wandel – ich zeige, dass alles möglich ist", scores:["licht":3,"wurzeln":1,"rhythmus":5,"wasser":3]),
                QuizOption(id:"d", text:"Durch Reinheit – ich spiegele das Beste zurück", scores:["licht":2,"wurzeln":3,"rhythmus":3,"wasser":5]),
            ]),
        QuizQuestion(id:"q10", text:"Was ist dein Herzensgebet?",
            context:"Das tiefste Sehnen deiner Seele",
            options:[
                QuizOption(id:"a", text:"Lass mich gesehen werden – in meiner vollen Pracht", scores:["licht":5,"wurzeln":2,"rhythmus":3,"wasser":2]),
                QuizOption(id:"b", text:"Lass mich verwurzelt sein – tief und unerschütterlich", scores:["licht":2,"wurzeln":5,"rhythmus":2,"wasser":3]),
                QuizOption(id:"c", text:"Lass mich frei sein – ohne Grenzen, ohne Erwartungen", scores:["licht":3,"wurzeln":1,"rhythmus":5,"wasser":4]),
                QuizOption(id:"d", text:"Lass mich rein sein – klar und unvermischt", scores:["licht":2,"wurzeln":3,"rhythmus":2,"wasser":5]),
            ]),
    ],
    profiles: [
        QuizProfile(id:"licht", title:"🌻 Die Sonnenblume", tagline:"Du wendest dein Gesicht immer dem Licht zu",
            description:"Die Sonnenblume folgt dem Licht, wohin auch immer es geht. Du bist eine Seele, die strahlt und andere anzieht. Deine Freude ist ansteckend, deine Energie aufbauend. Du brauchst Aufmerksamkeit nicht aus Eitelkeit, sondern weil du in Verbindung aufblühst.",
            icon:"sun.max.fill", color:Color(hex:"#F39C12"),
            stats:[QuizStat(label:"Strahlen", value:"97%", percent:0.97), QuizStat(label:"Verbindung", value:"91%", percent:0.91)],
            allies:["wildflower"], shareText:"Mein Blumenwesen ist die Sonnenblume – ich wende mich dem Licht zu 🌻"),
        QuizProfile(id:"wurzeln", title:"🪷 Die Lotusblume", tagline:"Du blühst dort, wo andere nur Schlamm sehen",
            description:"Die Lotusblume wächst aus dem tiefsten Schlamm und erhebt sich in makellose Schönheit. Du trägst eine außergewöhnliche innere Stärke: die Fähigkeit, durch das Schwerste hindurchzugehen und dennoch rein und offen zu bleiben.",
            icon:"drop.fill", color:Color(hex:"#E91E63"),
            stats:[QuizStat(label:"Verwurzelung", value:"96%", percent:0.96), QuizStat(label:"Reinheit", value:"94%", percent:0.94)],
            allies:["lotus","lavendel"], shareText:"Mein Blumenwesen ist die Lotusblume – ich blühe selbst im Schlamm 🪷"),
        QuizProfile(id:"rhythmus", title:"🌼 Die Wildblume", tagline:"Du wächst, wo niemand erwartet, dass etwas wächst",
            description:"Wildblumen brauchen keine Beete, keine Gärtner, keine Pflege nach Buch. Sie finden ihren Weg durch Asphalt, über Felsen, in Ritzen. Du bist genauso: unkontrollierbar in deiner Lebensfreude, authentisch in deiner Wildheit.",
            icon:"wind", color:Color(hex:"#8BC34A"),
            stats:[QuizStat(label:"Wildheit", value:"95%", percent:0.95), QuizStat(label:"Anpassung", value:"92%", percent:0.92)],
            allies:["sonnenblume"], shareText:"Mein Blumenwesen ist die Wildblume – ich wachse überall 🌼"),
        QuizProfile(id:"wasser", title:"🌸 Die Kirschblüte", tagline:"Du lebst im Augenblick, denn er ist alles",
            description:"Die Kirschblüte existiert nur für einen kurzen Moment – und gerade deshalb ist sie unvergesslich. Du verstehst die Vergänglichkeit als Geschenk, nicht als Verlust. Du lebst tief im Jetzt.",
            icon:"leaf.fill", color:Color(hex:"#F48FB1"),
            stats:[QuizStat(label:"Präsenz", value:"98%", percent:0.98), QuizStat(label:"Tiefe", value:"93%", percent:0.93)],
            allies:["lotus"], shareText:"Mein Blumenwesen ist die Kirschblüte – flüchtig, tief und unvergesslich 🌸"),
    ],
    dimensions: ["licht","wurzeln","rhythmus","wasser"]
)

// MARK: - Quiz Registry

let allQuizzes: [FullQuiz] = [
    loveLanguagesQuiz,
    krafttierQuiz,
    rpgQuiz,
    energiesteinQuiz,
    partyQuiz,
    blumenwesenQuiz,
] + extraQuizzes

// Scoring Engine
struct QuizEngine {
    /// Berechnet normalisierte Dimension-Scores (0–100)
    static func calculateScores(answers: [String: String], quiz: FullQuiz) -> [String: Double] {
        var raw: [String: Double] = [:]
        
        for question in quiz.questions {
            guard let chosenId = answers[question.id],
                  let option = question.options.first(where: { $0.id == chosenId }) else { continue }
            
            for (dim, val) in option.scores {
                raw[dim, default: 0] += val
            }
        }
        
        // Normalisieren 0–100
        let maxPossible = Double(quiz.questions.count) * 5.0
        return raw.mapValues { min(100, max(0, ($0 / maxPossible) * 100)) }
    }
    
    /// Profil-Matching: dominante Dimension → bestes Profil
    static func matchProfile(scores: [String: Double], quiz: FullQuiz) -> QuizProfile? {
        guard let dominant = scores.max(by: { $0.value < $1.value })?.key else {
            return quiz.profiles.first
        }
        
        // Exakter Match
        if let exact = quiz.profiles.first(where: { $0.id == dominant }) {
            return exact
        }
        
        // Partieller Match
        if let partial = quiz.profiles.first(where: {
            $0.id.contains(dominant) || dominant.contains($0.id)
        }) {
            return partial
        }
        
        // Party Quiz: score-basiertes Matching
        if quiz.id == "quiz.party_need.v1" {
            let avg = scores.values.reduce(0, +) / Double(max(scores.count, 1))
            if avg < 25 { return quiz.profiles.first }
            if avg < 50 { return quiz.profiles.dropFirst().first }
            if avg < 75 { return quiz.profiles.dropFirst(2).first }
            return quiz.profiles.last
        }
        
        return quiz.profiles.first
    }
}
