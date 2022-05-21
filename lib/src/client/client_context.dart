// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import 'oauth1_client.dart';
import 'oauth2_client.dart';
import 'oauth_tokens.dart';
import 'user_context.dart';

abstract class ClientContext {
  /// Returns the new instance of [ClientContext].
  factory ClientContext({
    required String bearerToken,
    OAuthTokens? oauthTokens,
  }) =>
      _ClientContext(
        bearerToken: bearerToken,
        oauthTokens: oauthTokens,
      );

  Future<http.Response> get(
    UserContext userContext,
    Uri uri, {
    Duration timeout = const Duration(seconds: 10),
  });

  Future<http.Response> post(
    UserContext userContext,
    Uri uri, {
    Map<String, String> headers = const {},
    dynamic body,
    Duration timeout = const Duration(seconds: 10),
  });

  Future<http.Response> delete(
    UserContext userContext,
    Uri uri, {
    Duration timeout = const Duration(seconds: 10),
  });

  Future<http.Response> put(
    UserContext userContext,
    Uri uri, {
    Map<String, String> headers = const {},
    dynamic body,
    Duration timeout = const Duration(seconds: 10),
  });

  Future<http.StreamedResponse> send(
    UserContext userContext,
    http.BaseRequest request, {
    Duration timeout = const Duration(seconds: 10),
  });

  /// Returns true if this context has an OAuth 1.0a client, otherwise false.
  bool get hasOAuth1Client;
}

class _ClientContext implements ClientContext {
  _ClientContext({
    required String bearerToken,
    OAuthTokens? oauthTokens,
  })  : _oauth1Client = oauthTokens != null
            ? OAuth1Client(
                consumerKey: oauthTokens.consumerKey,
                consumerSecret: oauthTokens.consumerSecret,
                accessToken: oauthTokens.accessToken,
                accessTokenSecret: oauthTokens.accessTokenSecret,
              )
            : null,
        _oauth2Client = OAuth2Client(bearerToken: bearerToken);

  /// The OAuth 1.0a client
  final OAuth1Client? _oauth1Client;

  /// The OAuth 2.0 client
  final OAuth2Client _oauth2Client;

  @override
  Future<http.Response> get(
    UserContext userContext,
    Uri uri, {
    Duration timeout = const Duration(seconds: 10),
  }) {
    if (userContext == UserContext.oauth2OrOAuth1 && hasOAuth1Client) {
      //! If an authentication token is set, the OAuth 1.0a method is given
      //! priority.
      return _oauth1Client!.get(uri, timeout: timeout);
    }

    return _oauth2Client.get(uri, timeout: timeout);
  }

  @override
  Future<http.Response> post(
    UserContext userContext,
    Uri uri, {
    Map<String, String> headers = const {},
    body,
    Duration timeout = const Duration(seconds: 10),
  }) {
    if (userContext == UserContext.oauth2OrOAuth1 && hasOAuth1Client) {
      //! If an authentication token is set, the OAuth 1.0a method is given
      //! priority.
      return _oauth1Client!.post(
        uri,
        headers: headers,
        body: body,
        timeout: timeout,
      );
    }

    return _oauth2Client.post(
      uri,
      headers: headers,
      body: body,
      timeout: timeout,
    );
  }

  @override
  Future<http.Response> delete(
    UserContext userContext,
    Uri uri, {
    Duration timeout = const Duration(seconds: 10),
  }) {
    if (userContext == UserContext.oauth2OrOAuth1 && hasOAuth1Client) {
      //! If an authentication token is set, the OAuth 1.0a method is given
      //! priority.
      return _oauth1Client!.delete(uri, timeout: timeout);
    }

    return _oauth2Client.delete(uri, timeout: timeout);
  }

  @override
  Future<http.Response> put(
    UserContext userContext,
    Uri uri, {
    Map<String, String> headers = const {},
    dynamic body,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (userContext == UserContext.oauth2OrOAuth1 && hasOAuth1Client) {
      //! If an authentication token is set, the OAuth 1.0a method is given
      //! priority.
      return _oauth1Client!.put(
        uri,
        headers: headers,
        body: body,
        timeout: timeout,
      );
    }

    return _oauth2Client.put(
      uri,
      headers: headers,
      body: body,
      timeout: timeout,
    );
  }

  @override
  Future<http.StreamedResponse> send(
    UserContext userContext,
    http.BaseRequest request, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (userContext == UserContext.oauth2OrOAuth1 && hasOAuth1Client) {
      //! If an authentication token is set, the OAuth 1.0a method is given
      //! priority.
      return _oauth1Client!.send(
        request,
        timeout: timeout,
      );
    }

    return _oauth2Client.send(
      request,
      timeout: timeout,
    );
  }

  @override
  bool get hasOAuth1Client => _oauth1Client != null;
}
