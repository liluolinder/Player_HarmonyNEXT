import { common, Want } from '@kit.AbilityKit';
import { AVVideoPlayer } from './player/AVVideoPlayer';
import { deviceInfo } from '@kit.BasicServicesKit';
import { FileUtil } from '@pura/harmony-utils';

export class EventData {
  launchWant: Want | undefined = undefined
}

@Entry
@Component
struct VideoIndex {
  @State
  private title: string = ''
  @State
  private url: string | undefined = undefined
  @State
  private videoHolder: string | undefined = undefined
  @State
  private backTrigger: boolean = false
  @StorageLink('appColorMode')
  colorMode: string = "system";

  aboutToAppear(): void {
    console.error("trying to play video")
    let eventData = new EventData()
    getContext(this).eventHub.emit('getAbilityData', eventData)
    let want = eventData.launchWant!
    if (want.parameters!['originalDevice'] != undefined) {
      console.error("find continue video")
      if (want.parameters!.originalDevice as string != deviceInfo.ODID) {
        console.error(`is remote file, url is: ${FileUtil.getUriFromPath(`${getContext(this)
          .distributedFilesDir}/${want.parameters!.hash}.vid`)}`)
        this.url = `dfs:${getContext(this).distributedFilesDir}/${want.parameters!.hash}.vid`
        this.videoHolder = want.parameters!.videoHolder as string
      } else {
        this.url = want.parameters!.url as string
      }
    } else {
      this.url = want.parameters!.url as string
    }
    this.title = want.parameters!.title as string
  }

  build() {
    WithTheme({
      colorMode: this.colorMode == "system" ? ThemeColorMode.SYSTEM :
        this.colorMode == "dark" ? ThemeColorMode.DARK : ThemeColorMode.LIGHT,
    }) {
      Stack() {
        AVVideoPlayer({
          title: this.title,
          url: this.url,
          videoHolder: this.videoHolder,
          backTrigger: this.backTrigger,
        })
      }
      .width("100%")
      .height("100%")
    }
  }

  onBackPress(): boolean | void {
    this.backTrigger = true;
    (getContext(this) as common.UIAbilityContext).terminateSelf()
      .then(() => {
      })
  }
}