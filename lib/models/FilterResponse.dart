// class FilterResponse {
//   String id;
//   String name;
//   String slug;
//   String type;
//   String orderBy;
//   int hasArchives;
//   List<Terms> terms;
//
//   FilterResponse(
//       {this.id,
//         this.name,
//         this.slug,
//         this.type,
//         this.orderBy,
//         this.hasArchives,
//         this.terms});
//
//   FilterResponse.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     slug = json['slug'];
//     type = json['type'];
//     orderBy = json['order_by'];
//     hasArchives = json['has_archives'];
//     if (json['terms'] != null) {
//       terms = new List<Terms>();
//       json['terms'].forEach((v) {
//         terms.add(new Terms.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     data['slug'] = this.slug;
//     data['type'] = this.type;
//     data['order_by'] = this.orderBy;
//     data['has_archives'] = this.hasArchives;
//     if (this.terms != null) {
//       data['terms'] = this.terms.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Terms {
//   int termId;
//   String name;
//   String slug;
//   int termGroup;
//   int termTaxonomyId;
//   String taxonomy;
//   String description;
//   int parent;
//   int count;
//   String filter;
//   bool isParent;
//   Terms(
//       {this.termId,
//         this.name,
//         this.slug,
//         this.termGroup,
//         this.termTaxonomyId,
//         this.taxonomy,
//         this.description,
//         this.parent,
//         this.count,
//         this.filter,
//       this.isParent});
//
//   Terms.fromJson(Map<String, dynamic> json) {
//     termId = json['term_id'];
//     name = json['name'];
//     slug = json['slug'];
//     termGroup = json['term_group'];
//     termTaxonomyId = json['term_taxonomy_id'];
//     taxonomy = json['taxonomy'];
//     description = json['description'];
//     parent = json['parent'];
//     count = json['count'];
//     filter = json['filter'];
//     isParent = json['isParent'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['term_id'] = this.termId;
//     data['name'] = this.name;
//     data['slug'] = this.slug;
//     data['term_group'] = this.termGroup;
//     data['term_taxonomy_id'] = this.termTaxonomyId;
//     data['taxonomy'] = this.taxonomy;
//     data['description'] = this.description;
//     data['parent'] = this.parent;
//     data['count'] = this.count;
//     data['filter'] = this.filter;
//     data['isParent'] = this.isParent;
//     return data;
//   }
// }
