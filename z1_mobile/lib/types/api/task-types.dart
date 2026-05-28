// ============================================================
// 任务相关类型
// 从 z1-mid SDK task-types.ts 翻译而来
// ============================================================

// Uses types from common.dart (int, String, etc.)

// ============================================================
// 重复周期
// ============================================================

enum RepeatCycle {
  no('no'),         // 不重复
  day('day'),       // 每天
  week('week'),     // 每周
  month('month');   // 每月

  final String value;
  const RepeatCycle(this.value);

  static RepeatCycle? fromValue(String? value) {
    if (value == null) return null;
    return RepeatCycle.values.cast<RepeatCycle?>().firstWhere(
      (e) => e?.value == value,
      orElse: () => null,
    );
  }
}

// ============================================================
// 任务状态
// ============================================================

enum TaskStatus {
  valid('valid'),     // 启用
  invalid('invalid'); // 停用

  final String value;
  const TaskStatus(this.value);

  static TaskStatus? fromValue(String? value) {
    if (value == null) return null;
    return TaskStatus.values.cast<TaskStatus?>().firstWhere(
      (e) => e?.value == value,
      orElse: () => null,
    );
  }
}

// ============================================================
// 可验收类型
// ============================================================

enum AllowCheckType {
  currentLeader('currentLeader'),   // 当前部门负责人
  higherLeader('higherLeader'),     // 上级部门负责人
  designation('designation'),       // 指定职员
  noCheck('nocheck');              // 不需要验收

  final String value;
  const AllowCheckType(this.value);

  static AllowCheckType? fromValue(String? value) {
    if (value == null) return null;
    return AllowCheckType.values.cast<AllowCheckType?>().firstWhere(
      (e) => e?.value == value,
      orElse: () => null,
    );
  }
}

// ============================================================
// 负责人类型
// ============================================================

enum ResponsibleType {
  employee('employee'), // 职员
  role('role');        // 角色

  final String value;
  const ResponsibleType(this.value);

  static ResponsibleType? fromValue(String? value) {
    if (value == null) return null;
    return ResponsibleType.values.cast<ResponsibleType?>().firstWhere(
      (e) => e?.value == value,
      orElse: () => null,
    );
  }
}

// ============================================================
// 任务模板分类
// ============================================================

enum TaskTemplateCate {
  goal('goal'),         // 目标
  operation('operation'), // 运营
  training('training'), // 培训
  marketing('marketing'); // 营销

  final String value;
  const TaskTemplateCate(this.value);

  static TaskTemplateCate? fromValue(String? value) {
    if (value == null) return null;
    return TaskTemplateCate.values.cast<TaskTemplateCate?>().firstWhere(
      (e) => e?.value == value,
      orElse: () => null,
    );
  }
}

// ============================================================
// 任务
// ============================================================

class Task {
  final int id;
  final int? cateID;
  final List<int> labelIDs;
  final String name;
  final int giveStartAt;
  final int? giveEndAt;
  final int duration;
  final RepeatCycle repeatCycle;
  final String introduction;
  final String description;
  final List<int> responsibleRoles;
  final List<String> responsibleEmployees;
  final AllowCheckType allowCheckType;
  final List<String> allowCheckEmployees;
  final bool isNeedSelfEvaluation;
  final int taskWeight;
  final TaskStatus status;
  final List<String> accessoriesUrls;
  final int? frequency;
  final List<int>? giveDays;
  final int? repeatNum;
  final List<String> sendUser;
  final int? responsibleStartRemind;
  final int? responsibleEndRemind;
  final int? checkStartRemind;
  final int createdAt;
  final String createdBy;
  final int updatedAt;
  final String updatedBy;
  final String? selfEvaluationDesc;

  Task({
    required this.id,
    this.cateID,
    required this.labelIDs,
    required this.name,
    required this.giveStartAt,
    this.giveEndAt,
    required this.duration,
    required this.repeatCycle,
    required this.introduction,
    required this.description,
    required this.responsibleRoles,
    required this.responsibleEmployees,
    required this.allowCheckType,
    required this.allowCheckEmployees,
    required this.isNeedSelfEvaluation,
    required this.taskWeight,
    required this.status,
    required this.accessoriesUrls,
    this.frequency,
    this.giveDays,
    this.repeatNum,
    required this.sendUser,
    this.responsibleStartRemind,
    this.responsibleEndRemind,
    this.checkStartRemind,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    this.selfEvaluationDesc,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      cateID: json['cateID'] as int?,
      labelIDs: (json['labelIDs'] as List<dynamic>).cast<int>(),
      name: json['name'] as String,
      giveStartAt: json['giveStartAt'] as int,
      giveEndAt: json['giveEndAt'] as int?,
      duration: json['duration'] as int? ?? 0,
      repeatCycle: RepeatCycle.fromValue(json['repeatCycle'] as String?) ?? RepeatCycle.no,
      introduction: json['introduction'] as String? ?? '',
      description: json['description'] as String? ?? '',
      responsibleRoles: (json['responsibleRoles'] as List<dynamic>).cast<int>(),
      responsibleEmployees: (json['responsibleEmployees'] as List<dynamic>).cast<String>(),
      allowCheckType: AllowCheckType.fromValue(json['allowCheckType'] as String?) ?? AllowCheckType.noCheck,
      allowCheckEmployees: (json['allowCheckEmployees'] as List<dynamic>).cast<String>(),
      isNeedSelfEvaluation: json['isNeedSelfEvaluation'] as bool? ?? false,
      taskWeight: json['taskWeight'] as int? ?? 0,
      status: TaskStatus.fromValue(json['status'] as String?) ?? TaskStatus.valid,
      accessoriesUrls: (json['accessoriesUrls'] as List<dynamic>).cast<String>(),
      frequency: json['frequency'] as int?,
      giveDays: (json['giveDays'] as List<dynamic>?)?.cast<int>(),
      repeatNum: json['repeatNum'] as int?,
      sendUser: (json['sendUser'] as List<dynamic>).cast<String>(),
      responsibleStartRemind: json['responsibleStartRemind'] as int?,
      responsibleEndRemind: json['responsibleEndRemind'] as int?,
      checkStartRemind: json['checkStartRemind'] as int?,
      createdAt: json['createdAt'] as int,
      createdBy: json['createdBy'] as String,
      updatedAt: json['updatedAt'] as int,
      updatedBy: json['updatedBy'] as String,
      selfEvaluationDesc: json['selfEvaluationDesc'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cateID': cateID,
      'labelIDs': labelIDs,
      'name': name,
      'giveStartAt': giveStartAt,
      'giveEndAt': giveEndAt,
      'duration': duration,
      'repeatCycle': repeatCycle.value,
      'introduction': introduction,
      'description': description,
      'responsibleRoles': responsibleRoles,
      'responsibleEmployees': responsibleEmployees,
      'allowCheckType': allowCheckType.value,
      'allowCheckEmployees': allowCheckEmployees,
      'isNeedSelfEvaluation': isNeedSelfEvaluation,
      'taskWeight': taskWeight,
      'status': status.value,
      'accessoriesUrls': accessoriesUrls,
      'frequency': frequency,
      'giveDays': giveDays,
      'repeatNum': repeatNum,
      'sendUser': sendUser,
      'responsibleStartRemind': responsibleStartRemind,
      'responsibleEndRemind': responsibleEndRemind,
      'checkStartRemind': checkStartRemind,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
      'selfEvaluationDesc': selfEvaluationDesc,
    };
  }
}

// ============================================================
// 任务模板
// ============================================================

class TaskTemplate {
  final String id;
  final TaskTemplateCate taskTemplateCate;
  final List<int> labelIDs;
  final String name;
  final int giveStartAt;
  final int giveEndAt;
  final String introduction;
  final String description;
  final AllowCheckType allowCheckType;
  final List<String> allowCheckEmployees;
  final bool isNeedSelfEvaluation;
  final int taskWeight;
  final TaskStatus status;
  final List<String> accessoriesUrls;
  final List<String> sendUser;
  final int? responsibleStartRemind;
  final int? responsibleEndRemind;
  final int? checkStartRemind;
  final int createdAt;
  final String createdBy;
  final int updatedAt;
  final String updatedBy;
  final String? selfEvaluationDesc;

  TaskTemplate({
    required this.id,
    required this.taskTemplateCate,
    required this.labelIDs,
    required this.name,
    required this.giveStartAt,
    required this.giveEndAt,
    required this.introduction,
    required this.description,
    required this.allowCheckType,
    required this.allowCheckEmployees,
    required this.isNeedSelfEvaluation,
    required this.taskWeight,
    required this.status,
    required this.accessoriesUrls,
    required this.sendUser,
    this.responsibleStartRemind,
    this.responsibleEndRemind,
    this.checkStartRemind,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    this.selfEvaluationDesc,
  });

  factory TaskTemplate.fromJson(Map<String, dynamic> json) {
    return TaskTemplate(
      id: json['id'] as String,
      taskTemplateCate: TaskTemplateCate.fromValue(json['taskTemplateCate'] as String?) ?? TaskTemplateCate.goal,
      labelIDs: (json['labelIDs'] as List<dynamic>).cast<int>(),
      name: json['name'] as String,
      giveStartAt: json['giveStartAt'] as int,
      giveEndAt: json['giveEndAt'] as int,
      introduction: json['introduction'] as String? ?? '',
      description: json['description'] as String? ?? '',
      allowCheckType: AllowCheckType.fromValue(json['allowCheckType'] as String?) ?? AllowCheckType.noCheck,
      allowCheckEmployees: (json['allowCheckEmployees'] as List<dynamic>).cast<String>(),
      isNeedSelfEvaluation: json['isNeedSelfEvaluation'] as bool? ?? false,
      taskWeight: json['taskWeight'] as int? ?? 0,
      status: TaskStatus.fromValue(json['status'] as String?) ?? TaskStatus.valid,
      accessoriesUrls: (json['accessoriesUrls'] as List<dynamic>).cast<String>(),
      sendUser: (json['sendUser'] as List<dynamic>).cast<String>(),
      responsibleStartRemind: json['responsibleStartRemind'] as int?,
      responsibleEndRemind: json['responsibleEndRemind'] as int?,
      checkStartRemind: json['checkStartRemind'] as int?,
      createdAt: json['createdAt'] as int,
      createdBy: json['createdBy'] as String,
      updatedAt: json['updatedAt'] as int,
      updatedBy: json['updatedBy'] as String,
      selfEvaluationDesc: json['selfEvaluationDesc'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskTemplateCate': taskTemplateCate.value,
      'labelIDs': labelIDs,
      'name': name,
      'giveStartAt': giveStartAt,
      'giveEndAt': giveEndAt,
      'introduction': introduction,
      'description': description,
      'allowCheckType': allowCheckType.value,
      'allowCheckEmployees': allowCheckEmployees,
      'isNeedSelfEvaluation': isNeedSelfEvaluation,
      'taskWeight': taskWeight,
      'status': status.value,
      'accessoriesUrls': accessoriesUrls,
      'sendUser': sendUser,
      'responsibleStartRemind': responsibleStartRemind,
      'responsibleEndRemind': responsibleEndRemind,
      'checkStartRemind': checkStartRemind,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
      'selfEvaluationDesc': selfEvaluationDesc,
    };
  }
}
