import '../../../core/extensions/compose_param_x.dart';
import '../../../core/extensions/feature_param_x.dart';
import '../../../core/extensions/module_param_x.dart';
import '../../../domain/params/app_integration/compose_param.dart';
import '../../text_modifiers/string_extension.dart';

abstract final class ComposeHelperTemplate {
  static String buildWrapper(ComposeParam param) {
    final featureUiSlice = [param.featureSnake, param.uiSlice].join('_');

    return switch (param.wrapper) {
      .dialog =>
        '''
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                title: Text(${param.moduleCamel}L10n.${featureUiSlice.camelCase}Title),
              ),
              _buildContent(context),
            ],
          ),
        ),   
''',
      .page =>
        '''
        return Scaffold(
          appBar: AppBar(
            title: Text(${param.moduleCamel}L10n.${featureUiSlice.camelCase}Title),            
          ),
          body: _buildContent(context),
        );
''',
      .section =>
        '''
        return AppSection(
          header: AppSectionHeader(
            titleText: ${param.moduleCamel}L10n.${featureUiSlice.camelCase}Title,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          ),
          child: _buildContent(context),
        );
''',
      .sheet =>
        '''
        return _buildContent(context);
''',
      _ =>
        '''
        return _buildContent(context);
''',
    };
  }

  static String buildFormWrapper(ComposeParam param) {
    final featureUiSlice = [param.featureSnake, param.uiSlice].join('_');

    return switch (param.wrapper) {
      .dialog =>
        '''
        return Stack(
          children: [
            Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    automaticallyImplyLeading: false,
                    title: Text(${param.moduleCamel}L10n.${featureUiSlice.camelCase}Title),
                  ),
                  _buildContent(context),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: _buildSubmit(context),
                  ),
                ],
              ),
            ),
            _buildOverlay(context),
          ],
        );
''',
      .page =>
        '''
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: Text(${param.moduleCamel}L10n.${featureUiSlice.camelCase}Title),
              ),
              body: _buildContent(context),
              bottomNavigationBar: AppBottomContainer(
                child: _buildSubmit(context),
              ),
            ),
            _buildOverlay(context),
          ],
        );
''',
      .section =>
        '''
        return Stack(
          children: [
            AppSection(
              header: AppSectionHeader(
                titleText: ${param.moduleCamel}L10n.${featureUiSlice.camelCase}Title,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
              ),
              child: _buildContent(context),
            ),
            _buildOverlay(context),
          ],
        );
''',
      .sheet =>
        '''
        return Stack(
          children: [
            _buildContent(context);
            _buildOverlay(context),
          ],
        );
''',
      _ =>
        '''
        return Stack(
          children: [
            _buildContent(context);
            _buildOverlay(context),
          ],
        );
''',
    };
  }

  static String buildMutationWrapper(ComposeParam param) {
    return switch (param.wrapper) {
      .dialog =>
        '''
        return Stack(
          children: [
            Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildContent(context),
                ],
              ),
            ),
            _buildOverlay(context),
          ],
        );
''',
      .page =>
        '''
        return Stack(
          children: [
            Scaffold(
              body: _buildContent(context),
            ),
            _buildOverlay(context),
          ],
        );
''',
      .section =>
        '''
        return Stack(
          children: [
            _buildContent(context),
            _buildOverlay(context),
          ],
        );
''',
      .sheet =>
        '''
        return Stack(
          children: [
            _buildContent(context);
            _buildOverlay(context),
          ],
        );
''',
      _ =>
        '''
        return Stack(
          children: [
            _buildContent(context);
            _buildOverlay(context),
          ],
        );
''',
    };
  }

  static String methodWrapper(ComposeParam param) {
    return switch (param.wrapper) {
      .dialog =>
        '''
  Future<dynamic> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => this,
    );
  }
''',
      .page => '',
      .section => '',
      .sheet =>
        '''
  Future<dynamic> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => this,
    );
  }        
''',
      _ => '',
    };
  }
}
