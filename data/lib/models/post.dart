import 'package:conduit/conduit.dart';

import 'author.dart';

class Post extends ManagedObject<_Post> implements _Post {}

class _Post {
  @primaryKey
  int? id;
  @Column(omitByDefault: true)
  String? content;
  String? preContent;
  String? name;
  @Relate(#postList, isRequired: true, onDelete: DeleteRule.cascade)
  Author? author;
}
