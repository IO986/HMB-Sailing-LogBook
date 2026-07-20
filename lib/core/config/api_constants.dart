const kApiBase = 'https://api.logbook.hmba.boats';

/// Web-application OAuth client ID, required by `google_sign_in` 7.x on
/// Android when not using `google-services.json`/Firebase (see
/// `google_sign_in_android`'s README, "Integration"). Not a secret — safe to
/// embed as a literal, same as Firebase's `default_web_client_id`; nothing
/// can be done with it without the corresponding server-side flow. Filled in
/// once the "Web application" OAuth client exists in the same GCP project as
/// the three Android clients (see docs/HANDOVER.md, KROK 0).
const kGoogleWebClientId =
    '67335624649-fpmgdt6cae47i6i8qq5ll6upvaivnofa.apps.googleusercontent.com';
