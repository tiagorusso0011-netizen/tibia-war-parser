import { 
  Controller, Post, UseInterceptors, UploadedFile, ParseFilePipe, MaxFileSizeValidator, HttpCode, HttpStatus
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { WarParserService } from './war-parser.service';
import * as fs from 'fs';

// Garante que a pasta uploads existe antes de receber o primeiro arquivo
if (!fs.existsSync('./uploads')) {
  fs.mkdirSync('./uploads');
}

@Controller('api/v1/wars')
export class WarParserController {
  constructor(private readonly parserService: WarParserService) {}

  @Post('upload')
  @HttpCode(HttpStatus.OK)
  @UseInterceptors(FileInterceptor('server_log', {
    storage: diskStorage({
      destination: './uploads',
      filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, `combat-log-${uniqueSuffix}${extname(file.originalname)}`);
      }
    })
  }))
  async uploadWarLog(
    @UploadedFile(
      new ParseFilePipe({
        validators: [new MaxFileSizeValidator({ maxSize: 1024 * 1024 * 10 })], // 10MB
      }),
    ) file: Express.Multer.File,
  ) {
    // Passa o arquivo que acabou de chegar para o Service (que vai chamar o Ruby)
    return this.parserService.processLogFile(file.path);
  }
}