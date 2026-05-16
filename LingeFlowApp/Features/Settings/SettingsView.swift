import SwiftUI

struct SettingsView: View {
    let routineCount: Int
    @Binding var notificationsEnabled: Bool
    let notificationAuthorizationState: NotificationAuthorizationState
    let appVersion: String
    let onDeleteAllRoutines: () -> Void

    @State private var showsDeleteConfirmation = false
    @State private var selectedLegalDocument: LegalDocument?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                Text("Réglages")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.lingeInk)

                SettingsHeaderCard(routineCount: routineCount)

                SettingsSection(title: "Rappels") {
                    SettingsToggleRow(
                        iconName: "bell.badge.fill",
                        iconColor: .lingePurple,
                        title: "Notifications",
                        subtitle: notificationSubtitle,
                        isOn: $notificationsEnabled
                    )
                }

                SettingsSection(title: "Synchronisation") {
                    SettingsInfoRow(
                        iconName: "icloud.fill",
                        iconColor: .lingeBlue,
                        title: "Sauvegarde iCloud",
                        subtitle: "Routines disponibles sur tes appareils",
                        trailingText: "Active"
                    )
                }

                SettingsSection(title: "Application") {
                    SettingsInfoRow(
                        iconName: "info.circle.fill",
                        iconColor: .lingePurple,
                        title: "Version",
                        subtitle: "Linge Flow",
                        trailingText: appVersion
                    )
                }

                SettingsSection(title: "Informations légales") {
                    SettingsNavigationRow(
                        iconName: "doc.text.fill",
                        iconColor: .lingeBlue,
                        title: "Mentions légales",
                        subtitle: "Éditeur, hébergement et propriété intellectuelle"
                    ) {
                        selectedLegalDocument = .legalNotices
                    }

                    Divider()
                        .padding(.leading, 78)

                    SettingsNavigationRow(
                        iconName: "hand.raised.fill",
                        iconColor: .lingeGreen,
                        title: "Politique de confidentialité",
                        subtitle: "Données, finalités et droits"
                    ) {
                        selectedLegalDocument = .privacyPolicy
                    }
                }

                SettingsSection(title: "Données") {
                    SettingsActionRow(
                        iconName: "trash.fill",
                        title: "Supprimer toutes les routines",
                        subtitle: routineCount == 0 ? "Aucune routine à supprimer" : "Effacer les \(routineCount) routines enregistrées",
                        isEnabled: routineCount > 0
                    ) {
                        showsDeleteConfirmation = true
                    }
                }

                Text("© 2026 Lux Audere")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.lingeMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 28)
        }
        .alert("Supprimer toutes les routines ?", isPresented: $showsDeleteConfirmation) {
            Button("Annuler", role: .cancel) {}
            Button("Supprimer", role: .destructive, action: onDeleteAllRoutines)
        } message: {
            Text("Cette action supprimera définitivement toutes les routines enregistrées.")
        }
        .sheet(item: $selectedLegalDocument) { document in
            LegalDocumentView(document: document)
        }
    }

    private var notificationSubtitle: String {
        switch notificationAuthorizationState {
        case .authorized:
            return notificationsEnabled ? "Les rappels sont activés" : "Les rappels sont désactivés"
        case .denied:
            return "Autorisation refusée dans les réglages iPhone"
        case .notDetermined:
            return "Active-les pour recevoir tes rappels"
        }
    }
}

private enum LegalDocument: String, Identifiable {
    case legalNotices
    case privacyPolicy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .legalNotices:
            return "Mentions légales"
        case .privacyPolicy:
            return "Politique de confidentialité"
        }
    }

    var webURL: URL {
        switch self {
        case .legalNotices:
            return URL(string: "https://ashurz.notion.site/Mention-L-gales-Linge-Flow-362b5894c0ef80e9a7ddd83432f9e20f?source=copy_link")!
        case .privacyPolicy:
            return URL(string: "https://ashurz.notion.site/Politique-de-confidentialit-362b5894c0ef80b1b89df190ca53bd4d?source=copy_link")!
        }
    }
}

private struct SettingsHeaderCard: View {
    let routineCount: Int

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.lingePurple.opacity(0.16), Color.lingePurple.opacity(0.07)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: "sparkles")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(Color.lingePurple)
            }
            .frame(width: 62, height: 62)

            VStack(alignment: .leading, spacing: 5) {
                Text("Linge Flow")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.lingeInk)

                Text(routineCountText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.lingeMuted)
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.black.opacity(0.055), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.045), radius: 14, x: 0, y: 8)
    }

    private var routineCountText: String {
        if routineCount == 0 {
            return "Aucune routine enregistrée"
        }

        return "\(routineCount) routine\(routineCount > 1 ? "s" : "") enregistrée\(routineCount > 1 ? "s" : "")"
    }
}

private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.lingeInk)

            VStack(spacing: 0) {
                content
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            }
        }
    }
}

private struct SettingsToggleRow: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            SettingsIcon(iconName: iconName, color: iconColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.lingeInk)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.lingeMuted)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.lingePurple)
        }
        .padding(16)
    }
}

private struct SettingsInfoRow: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let trailingText: String

    var body: some View {
        HStack(spacing: 14) {
            SettingsIcon(iconName: iconName, color: iconColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.lingeInk)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.lingeMuted)
            }

            Spacer()

            Text(trailingText)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.lingeMuted)
        }
        .padding(16)
    }
}

private struct SettingsActionRow: View {
    let iconName: String
    let title: String
    let subtitle: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                SettingsIcon(iconName: iconName, color: isEnabled ? .lingeDestructive : .lingeMuted)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(isEnabled ? Color.lingeDestructive : Color.lingeMuted)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.lingeMuted)
                }

                Spacer()
            }
            .padding(16)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

private struct SettingsNavigationRow: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                SettingsIcon(iconName: iconName, color: iconColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.lingeInk)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.lingeMuted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.lingeMuted)
            }
            .padding(16)
        }
        .buttonStyle(.plain)
    }
}

private struct SettingsIcon: View {
    let iconName: String
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(color.opacity(0.12))

            Image(systemName: iconName)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(color)
        }
        .frame(width: 48, height: 48)
    }
}

private struct LegalDocumentView: View {
    let document: LegalDocument

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Link(destination: document.webURL) {
                        HStack(spacing: 10) {
                            Image(systemName: "safari.fill")
                            Text("Voir la version en ligne")
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.lingePurple)
                    }

                    ForEach(sections) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            if !section.title.isEmpty {
                                Text(section.title)
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.lingeInk)
                            }

                            Text(section.body)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(Color.lingeInk.opacity(0.88))
                                .lineSpacing(3)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 28)
            }
            .background(Color.lingeBackground)
            .navigationTitle(document.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var sections: [LegalSection] {
        switch document {
        case .legalNotices:
            return [
                LegalSection(
                    title: "Dernière mise à jour",
                    body: "16 mai 2026"
                ),
                LegalSection(
                    title: "Éditeur de l’application",
                    body: "L’application Linge Flow est éditée par Lux Audere.\n\nEmail de contact : dev@ashuraz.xyz\n\nLinge Flow est une application mobile permettant de créer et gérer des rappels liés aux routines de linge : machines, draps, serviettes, vêtements blancs, linge foncé et autres textiles à entretenir."
                ),
                LegalSection(
                    title: "Hébergement",
                    body: "Les pages d’assistance, de mentions légales et de politique de confidentialité sont hébergées par :\n\nNotion Labs, Inc.\n548 Market Street, #74567\nSan Francisco, CA 94104-5401\nÉtats-Unis"
                ),
                LegalSection(
                    title: "Contact",
                    body: "Pour toute question concernant l’application, son fonctionnement, les données personnelles ou une demande d’assistance, vous pouvez contacter l’éditeur à l’adresse suivante :\n\ndev@ashuraz.xyz"
                ),
                LegalSection(
                    title: "Propriété intellectuelle",
                    body: "L’application Linge Flow, son nom, son logo, son interface, ses textes, ses visuels et ses éléments graphiques sont protégés par le droit de la propriété intellectuelle.\n\nToute reproduction, modification, distribution ou utilisation non autorisée de ces éléments est interdite sans accord préalable écrit de l’éditeur."
                ),
                LegalSection(
                    title: "Responsabilité",
                    body: "Linge Flow est une application d’aide à l’organisation personnelle. Elle permet de créer des rappels liés aux routines de linge, mais ne garantit pas que les notifications seront toujours reçues dans toutes les situations.\n\nLa réception des rappels peut dépendre des réglages de l’appareil, des autorisations de notification, du système iOS, du mode économie d’énergie, de la connexion ou d’autres paramètres indépendants de l’application.\n\nL’utilisateur reste responsable de l’organisation de ses tâches domestiques et de la vérification de ses rappels."
                ),
                LegalSection(
                    title: "Droit applicable",
                    body: "Les présentes mentions légales sont soumises au droit français."
                ),
                LegalSection(
                    title: "",
                    body: "© 2026 Lux Audere. Tous droits réservés."
                )
            ]
        case .privacyPolicy:
            return [
                LegalSection(
                    title: "Version de l’application",
                    body: "0.1"
                ),
                LegalSection(
                    title: "Dernière mise à jour",
                    body: "16 mai 2026"
                ),
                LegalSection(
                    title: "",
                    body: "Linge Flow respecte la vie privée de ses utilisateurs. Cette politique de confidentialité explique quelles données peuvent être traitées lors de l’utilisation de l’application, pourquoi elles sont utilisées et quels sont vos droits."
                ),
                LegalSection(
                    title: "Responsable du traitement",
                    body: "Le responsable du traitement est Lux Audere.\n\nEmail de contact : dev@ashuraz.xyz\n\nPour toute question concernant cette politique de confidentialité ou vos données personnelles, vous pouvez envoyer un email à l’adresse indiquée ci-dessus."
                ),
                LegalSection(
                    title: "Données traitées par l’application",
                    body: "Linge Flow permet à l’utilisateur de créer des routines de linge, comme des rappels pour les machines, les draps, les serviettes, les vêtements blancs, le linge foncé ou d’autres textiles.\n\nSelon l’utilisation de l’application, les données suivantes peuvent être enregistrées : le nom des routines créées par l’utilisateur, la fréquence des rappels choisis, la date et l’heure du prochain rappel, l’état d’une routine et les préférences liées aux notifications.\n\nL’application ne demande pas la création d’un compte utilisateur dans sa version actuelle."
                ),
                LegalSection(
                    title: "Finalité du traitement",
                    body: "Les données sont utilisées uniquement pour permettre le fonctionnement de l’application.\n\nElles servent à créer des routines de linge, planifier des rappels, afficher les tâches à faire, organiser les tâches à venir et envoyer des notifications lorsque l’utilisateur les active.\n\nLes données ne sont pas utilisées à des fins publicitaires."
                ),
                LegalSection(
                    title: "Notifications",
                    body: "Linge Flow peut demander l’autorisation d’envoyer des notifications.\n\nCes notifications servent uniquement à rappeler à l’utilisateur ses routines de linge au moment choisi.\n\nL’utilisateur peut activer ou désactiver les notifications à tout moment depuis les réglages de son appareil iOS et dans les réglages de l’application."
                ),
                LegalSection(
                    title: "Stockage des données",
                    body: "Dans la version actuelle, les données de Linge Flow sont stockées localement sur l’appareil de l’utilisateur et peuvent être synchronisées via iCloud afin d’être disponibles sur ses appareils connectés au même compte Apple. Elles ne sont pas envoyées vers un serveur appartenant à l’éditeur."
                ),
                LegalSection(
                    title: "Partage des données",
                    body: "Les données créées dans Linge Flow ne sont pas vendues, louées ou partagées avec des annonceurs.\n\nL’application ne partage pas les routines de linge de l’utilisateur avec des tiers à des fins marketing.\n\nCertaines données peuvent toutefois être traitées par Apple dans le cadre du fonctionnement normal d’iOS, des notifications, de l’App Store ou des services système utilisés par l’appareil. Ces traitements sont soumis aux politiques de confidentialité d’Apple."
                ),
                LegalSection(
                    title: "Données d’analyse et publicité",
                    body: "Dans sa version actuelle, Linge Flow n’utilise pas de publicité personnalisée.\n\nSi des outils d’analyse, de suivi d’erreurs ou de statistiques sont ajoutés à l’avenir, cette politique de confidentialité sera mise à jour afin d’expliquer clairement quelles données sont collectées et dans quel but."
                ),
                LegalSection(
                    title: "Durée de conservation",
                    body: "Les données liées aux routines sont conservées tant que l’utilisateur garde l’application installée ou tant qu’il ne supprime pas les routines depuis l’application.\n\nEn cas de désinstallation de l’application, les données locales peuvent être supprimées de l’appareil."
                ),
                LegalSection(
                    title: "Droits des utilisateurs",
                    body: "Conformément au Règlement général sur la protection des données, l’utilisateur peut demander l’accès, la rectification, l’effacement ou la limitation du traitement de ses données personnelles lorsque cela est applicable.\n\nPour exercer ces droits, l’utilisateur peut contacter l’éditeur à l’adresse suivante :\n\ndev@ashuraz.xyz\n\nUne réponse sera apportée dans un délai raisonnable."
                ),
                LegalSection(
                    title: "Sécurité",
                    body: "Linge Flow met en œuvre des mesures raisonnables pour limiter l’accès non autorisé aux données utilisées par l’application.\n\nL’utilisateur reste toutefois responsable de la sécurité de son appareil, de son code de déverrouillage et de son compte Apple."
                ),
                LegalSection(
                    title: "Utilisation par les mineurs",
                    body: "Linge Flow est une application d’organisation personnelle et domestique. Elle ne cible pas spécifiquement les enfants et ne collecte pas volontairement de données concernant des mineurs."
                ),
                LegalSection(
                    title: "Modifications de la politique",
                    body: "Cette politique de confidentialité peut être modifiée à tout moment, notamment en cas d’évolution de l’application, d’ajout de fonctionnalités, de synchronisation, de compte utilisateur, d’analyse ou de services tiers.\n\nLa date de mise à jour indiquée en haut de cette page permet d’identifier la dernière version applicable."
                ),
                LegalSection(
                    title: "Contact",
                    body: "Pour toute question concernant cette politique de confidentialité ou l’application Linge Flow, vous pouvez contacter :\n\ndev@ashuraz.xyz"
                ),
                LegalSection(
                    title: "",
                    body: "© 2026 Lux Audere. Tous droits réservés."
                )
            ]
        }
    }
}

private struct LegalSection: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

